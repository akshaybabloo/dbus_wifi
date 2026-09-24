import 'dart:typed_data';

import 'package:dbus/dbus.dart';
import 'package:dbus_wifi/interfaces/bluez_gatt_characteristic_object.dart';
import 'package:dbus_wifi/models/ble_gatt_characteristic.dart';
import 'package:dbus_wifi/models/ble_gatt_exception.dart';
import 'package:dbus_wifi/models/ble_request.dart';

const _interface = 'org.bluez.GattCharacteristic1';

/// Exports a [BleGattCharacteristic] as an `org.bluez.GattCharacteristic1` object
class GattCharacteristicObject extends OrgBluezGattCharacteristic1 {
  final BleGattCharacteristic characteristic;
  final DBusObjectPath service;
  final void Function(bool notifying) onNotifyingChanged;

  Uint8List _value;
  bool _notifying = false;

  GattCharacteristicObject({
    required super.path,
    required this.service,
    required this.characteristic,
    required this.onNotifyingChanged,
  }) : _value = characteristic.initialValue ?? Uint8List(0);

  bool get notifying => _notifying;

  Uint8List get value => _value;

  /// Updates the value and, while a device is subscribed, sends it as a notification.
  /// Returns whether a notification was sent.
  Future<bool> notify(Uint8List value) async {
    _value = value;
    if (!_notifying) {
      return false;
    }
    await emitPropertiesChanged(_interface, changedProperties: {'Value': DBusArray.byte(value)});
    return true;
  }

  Map<String, DBusValue> get _properties => {
        'UUID': DBusString(characteristic.uuid),
        'Service': service,
        'Value': DBusArray.byte(_value),
        'Notifying': DBusBoolean(_notifying),
        'Flags': DBusArray.string(characteristic.flags.map((flag) => flag.value)),
      };

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {_interface: _properties};

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    final value = interface == _interface ? _properties[name] : null;
    return value == null ? DBusMethodErrorResponse.unknownProperty() : DBusGetPropertyResponse(value);
  }

  @override
  Future<DBusMethodResponse> getAllProperties(String interface) async {
    return DBusGetAllPropertiesResponse(interface == _interface ? _properties : {});
  }

  @override
  Future<DBusMethodResponse> doReadValue(Map<String, DBusValue> options) async {
    if (!characteristic.canRead) {
      return _error(BleGattError.notPermitted);
    }
    final request = BleRequest.fromOptions(options);

    final Uint8List value;
    try {
      final onRead = characteristic.onRead;
      value = onRead == null ? _value : await onRead(request);
    } on BleGattException catch (e) {
      return _error(e.error, e.message);
    } catch (e) {
      return _error(BleGattError.failed, e.toString());
    }

    if (request.offset > value.length) {
      return _error(BleGattError.invalidOffset);
    }
    return DBusMethodSuccessResponse([DBusArray.byte(value.sublist(request.offset))]);
  }

  @override
  Future<DBusMethodResponse> doWriteValue(List<int> value, Map<String, DBusValue> options) async {
    if (!characteristic.canWrite) {
      return _error(BleGattError.notPermitted);
    }
    final request = BleRequest.fromOptions(options);
    final bytes = Uint8List.fromList(value);

    final onWrite = characteristic.onWrite;
    if (onWrite == null) {
      if (request.offset > _value.length) {
        return _error(BleGattError.invalidOffset);
      }
      _value = Uint8List.fromList([..._value.sublist(0, request.offset), ...bytes]);
      return DBusMethodSuccessResponse();
    }

    try {
      await onWrite(bytes, request);
    } on BleGattException catch (e) {
      return _error(e.error, e.message);
    } catch (e) {
      return _error(BleGattError.failed, e.toString());
    }
    return DBusMethodSuccessResponse();
  }

  @override
  Future<DBusMethodResponse> doStartNotify() => _setNotifying(true);

  @override
  Future<DBusMethodResponse> doStopNotify() => _setNotifying(false);

  @override
  Future<DBusMethodResponse> doConfirm() async => DBusMethodSuccessResponse();

  Future<DBusMethodResponse> _setNotifying(bool notifying) async {
    if (!characteristic.canNotify) {
      return _error(BleGattError.notSupported);
    }
    if (_notifying != notifying) {
      _notifying = notifying;
      await emitPropertiesChanged(_interface, changedProperties: {'Notifying': DBusBoolean(notifying)});
      onNotifyingChanged(notifying);
    }
    return DBusMethodSuccessResponse();
  }

  DBusMethodErrorResponse _error(BleGattError error, [String? message]) {
    return DBusMethodErrorResponse(error.errorName, message == null ? [] : [DBusString(message)]);
  }
}
