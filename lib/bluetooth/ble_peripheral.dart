import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:dbus/dbus.dart';
import 'package:dbus_wifi/bluetooth/advertisement_object.dart';
import 'package:dbus_wifi/bluetooth/gatt_application_object.dart';
import 'package:dbus_wifi/bluetooth/gatt_characteristic_object.dart';
import 'package:dbus_wifi/bluetooth/gatt_service_object.dart';
import 'package:dbus_wifi/dbus_bluetooth.dart';
import 'package:dbus_wifi/interfaces/bluez_advertising_manager_remote_object.dart';
import 'package:dbus_wifi/interfaces/bluez_gatt_manager_remote_object.dart';

/// A change in whether a remote device is subscribed to a characteristic
typedef BleSubscription = ({BleGattCharacteristic characteristic, bool notifying});

/// Runs a GATT server and LE advertisement on the local adapter through BlueZ
class BlePeripheral {
  final DbusBluetooth _bluetooth;
  final String _basePath;

  final _subscriptions = StreamController<BleSubscription>.broadcast();
  final _released = StreamController<void>.broadcast();

  final _objects = <DBusObject>[];
  final _characteristics = LinkedHashMap<BleGattCharacteristic, GattCharacteristicObject>.identity();
  DBusObjectPath? _adapter;
  DBusObjectPath? _applicationPath;
  DBusObjectPath? _advertisementPath;

  /// [basePath] is the D-Bus path the application and advertisement objects are exported under.
  /// Use a different one for each peripheral sharing a D-Bus connection.
  BlePeripheral(this._bluetooth, {String basePath = '/dbus_wifi/ble'}) : _basePath = basePath;

  bool get isRunning => _objects.isNotEmpty;

  /// Whether the advertisement is currently registered
  bool get isAdvertising => _advertisementPath != null;

  /// Emits when a remote device starts or stops notifications on a characteristic
  Stream<BleSubscription> get subscriptions => _subscriptions.stream;

  /// Emits when BlueZ releases the advertisement, for example when the adapter powers off
  Stream<void> get released => _released.stream;

  /// Exports [services], registers them with BlueZ and starts advertising
  ///
  /// Throws a [StateError] if already running. If registration fails everything is undone before rethrowing.
  Future<void> start({required List<BleGattService> services, required BleAdvertisement advertisement}) async {
    if (isRunning) {
      throw StateError('BLE peripheral is already running.');
    }
    final client = _bluetooth.client;
    final adapter = await _bluetooth.adapterPath;
    _adapter = adapter;

    final applicationPath = DBusObjectPath('$_basePath/app');
    final application = GattApplicationObject(path: applicationPath);
    await _register(application);

    for (final (i, service) in services.indexed) {
      final servicePath = DBusObjectPath('${applicationPath.value}/service$i');
      final serviceObject = GattServiceObject(path: servicePath, service: service);
      application.children.add(serviceObject);
      await _register(serviceObject);

      for (final (j, characteristic) in service.characteristics.indexed) {
        final object = GattCharacteristicObject(
          path: DBusObjectPath('${servicePath.value}/char$j'),
          service: servicePath,
          characteristic: characteristic,
          onNotifyingChanged: (notifying) {
            _subscriptions.add((characteristic: characteristic, notifying: notifying));
          },
        );
        _characteristics[characteristic] = object;
        application.children.add(object);
        await _register(object);
      }
    }

    final advertisementPath = DBusObjectPath('$_basePath/advertisement');
    await _register(
      AdvertisementObject(
        path: advertisementPath,
        advertisement: advertisement,
        onRelease: () {
          _advertisementPath = null;
          _released.add(null);
        },
      ),
    );

    try {
      await OrgBluezGattManager1(client, 'org.bluez', adapter).callRegisterApplication(applicationPath, {});
      _applicationPath = applicationPath;
      await OrgBluezLEAdvertisingManager1(client, 'org.bluez', adapter)
          .callRegisterAdvertisement(advertisementPath, {});
      _advertisementPath = advertisementPath;
    } catch (e) {
      await stop();
      rethrow;
    }
  }

  /// Stops advertising, unregisters the GATT application and removes the exported objects
  ///
  /// Local objects are always removed; the first BlueZ error, if any, is rethrown afterwards.
  Future<void> stop() async {
    final client = _bluetooth.client;
    final adapter = _adapter;
    Object? failure;

    final advertisementPath = _advertisementPath;
    if (adapter != null && advertisementPath != null) {
      try {
        await OrgBluezLEAdvertisingManager1(client, 'org.bluez', adapter)
            .callUnregisterAdvertisement(advertisementPath);
      } catch (e) {
        failure ??= e;
      }
    }
    final applicationPath = _applicationPath;
    if (adapter != null && applicationPath != null) {
      try {
        await OrgBluezGattManager1(client, 'org.bluez', adapter).callUnregisterApplication(applicationPath);
      } catch (e) {
        failure ??= e;
      }
    }

    for (final object in _objects.reversed) {
      await client.unregisterObject(object);
    }
    _objects.clear();
    _characteristics.clear();
    _advertisementPath = null;
    _applicationPath = null;
    _adapter = null;

    if (failure != null) {
      throw failure;
    }
  }

  /// Sends [value] as a notification on [characteristic] and updates its readable value
  ///
  /// Returns false when no device is subscribed. Keep [value] within [BleRequest.maxNotifyLength].
  Future<bool> notify(BleGattCharacteristic characteristic, Uint8List value) {
    return _objectFor(characteristic).notify(value);
  }

  /// Whether a remote device is subscribed to [characteristic]
  bool isNotifying(BleGattCharacteristic characteristic) => _objectFor(characteristic).notifying;

  /// Stops the peripheral and closes its streams
  Future<void> dispose() async {
    try {
      await stop();
    } finally {
      await _subscriptions.close();
      await _released.close();
    }
  }

  GattCharacteristicObject _objectFor(BleGattCharacteristic characteristic) {
    final object = _characteristics[characteristic];
    if (object == null) {
      throw ArgumentError.value(characteristic, 'characteristic', 'Not part of the running peripheral');
    }
    return object;
  }

  Future<void> _register(DBusObject object) async {
    await _bluetooth.client.registerObject(object);
    _objects.add(object);
  }
}
