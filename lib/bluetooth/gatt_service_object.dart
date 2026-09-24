import 'package:dbus/dbus.dart';
import 'package:dbus_wifi/interfaces/bluez_gatt_service_object.dart';
import 'package:dbus_wifi/models/ble_gatt_service.dart';

const _interface = 'org.bluez.GattService1';

/// Exports a [BleGattService] as an `org.bluez.GattService1` object
class GattServiceObject extends OrgBluezGattService1 {
  final BleGattService service;

  GattServiceObject({required super.path, required this.service});

  Map<String, DBusValue> get _properties => {
        'UUID': DBusString(service.uuid),
        'Primary': DBusBoolean(service.primary),
        'Includes': DBusArray.objectPath([]),
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
}
