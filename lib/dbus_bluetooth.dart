import 'dart:async';

import 'package:dbus/dbus.dart';
import 'package:dbus_wifi/interfaces/bluez_adapter_remote_object.dart';
import 'package:dbus_wifi/interfaces/bluez_device_remote_object.dart';
import 'package:dbus_wifi/models/ble_device.dart';
import 'package:dbus_wifi/models/bluetooth_transport.dart';

export 'package:dbus_wifi/bluetooth/ble_peripheral.dart';
export 'package:dbus_wifi/models/ble_advertisement.dart';
export 'package:dbus_wifi/models/ble_characteristic_flag.dart';
export 'package:dbus_wifi/models/ble_device.dart';
export 'package:dbus_wifi/models/ble_gatt_characteristic.dart';
export 'package:dbus_wifi/models/ble_gatt_exception.dart';
export 'package:dbus_wifi/models/ble_gatt_service.dart';
export 'package:dbus_wifi/models/ble_request.dart';
export 'package:dbus_wifi/models/bluetooth_transport.dart';

const _bluez = 'org.bluez';
const _adapterInterface = 'org.bluez.Adapter1';
const _deviceInterface = 'org.bluez.Device1';

/// A class to interact with the local Bluetooth adapter using BlueZ over D-Bus
class DbusBluetooth {
  final DBusClient _client;
  final bool _ownsClient;
  late final DBusRemoteObjectManager _manager = DBusRemoteObjectManager(
    _client,
    name: _bluez,
    path: DBusObjectPath('/'),
  );
  DBusObjectPath? _adapter;

  /// Uses the system bus unless a [client] is given, which is then left open by [close]
  DbusBluetooth({DBusClient? client})
      : _client = client ?? DBusClient.system(),
        _ownsClient = client == null;

  /// The D-Bus connection, shared with [BlePeripheral]
  DBusClient get client => _client;

  /// Checks if a Bluetooth adapter is available
  Future<bool> get hasAdapter async => await _findAdapter() != null;

  /// The D-Bus path of the first adapter, for example `/org/bluez/hci0`
  ///
  /// Throws an exception if no adapter is found.
  Future<DBusObjectPath> get adapterPath async {
    final adapter = await _findAdapter();
    if (adapter == null) {
      throw Exception('No Bluetooth adapter found.');
    }
    return adapter;
  }

  /// Returns whether the adapter is powered on
  Future<bool> get isPowered async => (await _adapterObject()).getPowered();

  /// Powers the adapter on or off
  ///
  /// Returns the new state of the adapter (true = on, false = off).
  Future<bool> setPowered(bool powered) async {
    final adapter = await _adapterObject();
    await adapter.setPowered(powered);
    return adapter.getPowered();
  }

  /// The adapter's Bluetooth address
  Future<String> get address async => (await _adapterObject()).getAddress();

  /// The adapter's friendly name
  Future<String> get alias async => (await _adapterObject()).getAlias();

  /// Sets the adapter's friendly name, which is also used as the GAP device name
  Future<void> setAlias(String alias) async => (await _adapterObject()).setAlias(alias);

  /// Scans for nearby Bluetooth devices
  ///
  /// Runs discovery for [timeout] and returns the devices seen during it, strongest signal first.
  /// Throws an exception if no adapter is found or the adapter is off.
  Future<List<BleDevice>> scan({
    Duration timeout = const Duration(seconds: 5),
    BluetoothTransport transport = BluetoothTransport.le,
  }) async {
    final adapter = await _adapterObject();
    if (!await adapter.getPowered()) {
      throw Exception('Bluetooth adapter is powered off.');
    }

    await adapter.callSetDiscoveryFilter({'Transport': DBusString(transport.value)});
    await adapter.callStartDiscovery();
    final List<BleDevice> devices;
    try {
      await Future.delayed(timeout);
      devices = await _devices(where: (device) => device.rssi != null);
    } finally {
      await adapter.callStopDiscovery();
      await adapter.callSetDiscoveryFilter({});
    }

    devices.sort((a, b) => b.rssi!.compareTo(a.rssi!));
    return devices;
  }

  /// Devices currently connected to the adapter
  Future<List<BleDevice>> get connectedDevices => _devices(where: (device) => device.connected);

  /// Emits a [BleDevice] each time a device connects to or disconnects from the adapter
  ///
  /// Each access returns a new stream that only reports changes made after it is listened to.
  Stream<BleDevice> get connectionChanges {
    final connected = <DBusObjectPath, BleDevice>{};
    return _manager.signals.asyncExpand((signal) async* {
      if (signal is DBusPropertiesChangedSignal &&
          signal.propertiesInterface == _deviceInterface &&
          signal.changedProperties.containsKey('Connected')) {
        final device = await _readDevice(signal.path, signal.changedProperties['Connected']!.asBoolean());
        if (device.connected) {
          connected[device.path] = device;
        } else {
          connected.remove(device.path);
        }
        yield device;
      } else if (signal is DBusObjectManagerInterfacesAddedSignal) {
        final properties = signal.interfacesAndProperties[_deviceInterface];
        if (properties != null && properties['Connected']?.asBoolean() == true) {
          final device = _deviceFromProperties(signal.changedPath, properties);
          connected[device.path] = device;
          yield device;
        }
      } else if (signal is DBusObjectManagerInterfacesRemovedSignal && signal.interfaces.contains(_deviceInterface)) {
        final device = connected.remove(signal.changedPath);
        if (device != null) {
          yield BleDevice(path: device.path, address: device.address, name: device.name, connected: false);
        }
      }
    });
  }

  /// Disconnects a remote device from the adapter
  Future<void> disconnect(DBusObjectPath device) async {
    await OrgBluezDevice1(_client, _bluez, device).callDisconnect();
  }

  /// Closes the D-Bus client connection if this instance created it
  Future<void> close() async {
    if (_ownsClient) {
      await _client.close();
    }
  }

  Future<DBusObjectPath?> _findAdapter() async {
    if (_adapter != null) {
      return _adapter;
    }
    final objects = await _manager.getManagedObjects();
    for (final MapEntry(key: path, value: interfaces) in objects.entries) {
      if (interfaces.containsKey(_adapterInterface)) {
        return _adapter = path;
      }
    }
    return null;
  }

  Future<List<BleDevice>> _devices({required bool Function(BleDevice device) where}) async {
    final adapter = await adapterPath;
    final objects = await _manager.getManagedObjects();
    return [
      for (final MapEntry(key: path, value: interfaces) in objects.entries)
        if (interfaces[_deviceInterface] case final properties? when properties['Adapter'] == adapter)
          _deviceFromProperties(path, properties),
    ].where(where).toList();
  }

  Future<OrgBluezAdapter1> _adapterObject() async => OrgBluezAdapter1(_client, _bluez, await adapterPath);

  Future<BleDevice> _readDevice(DBusObjectPath path, bool connected) async {
    try {
      final properties = await OrgBluezDevice1(_client, _bluez, path).getAllProperties(_deviceInterface);
      return _deviceFromProperties(path, {...properties, 'Connected': DBusBoolean(connected)});
    } on DBusMethodResponseException {
      // The device object can disappear before we read it; the path still carries its address.
      return BleDevice(path: path, address: BleDevice.addressFromPath(path), connected: connected);
    }
  }

  BleDevice _deviceFromProperties(DBusObjectPath path, Map<String, DBusValue> properties) {
    return BleDevice(
      path: path,
      address: properties['Address']?.asString() ?? BleDevice.addressFromPath(path),
      name: properties['Name']?.asString(),
      connected: properties['Connected']?.asBoolean() ?? false,
      rssi: properties['RSSI']?.asInt16(),
    );
  }
}
