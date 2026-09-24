import 'package:dbus/dbus.dart';
import 'package:dbus_wifi/interfaces/bluez_advertisement_object.dart';
import 'package:dbus_wifi/models/ble_advertisement.dart';

const _interface = 'org.bluez.LEAdvertisement1';

/// Exports a [BleAdvertisement] as an `org.bluez.LEAdvertisement1` object
class AdvertisementObject extends OrgBluezLEAdvertisement1 {
  final BleAdvertisement advertisement;

  /// Called when BlueZ drops the advertisement, for example when the adapter powers off
  final void Function() onRelease;

  AdvertisementObject({required super.path, required this.advertisement, required this.onRelease});

  Map<String, DBusValue> get _properties {
    final localName = advertisement.localName;
    final discoverable = advertisement.discoverable;
    return {
      'Type': DBusString('peripheral'),
      if (advertisement.serviceUuids.isNotEmpty) 'ServiceUUIDs': DBusArray.string(advertisement.serviceUuids),
      if (advertisement.manufacturerData.isNotEmpty)
        'ManufacturerData': DBusDict(
          DBusSignature('q'),
          DBusSignature('v'),
          advertisement.manufacturerData.map(
            (company, data) => MapEntry(DBusUint16(company), DBusVariant(DBusArray.byte(data))),
          ),
        ),
      if (advertisement.serviceData.isNotEmpty)
        'ServiceData': DBusDict.stringVariant(
          advertisement.serviceData.map((uuid, data) => MapEntry(uuid, DBusArray.byte(data))),
        ),
      if (localName != null) 'LocalName': DBusString(localName),
      if (advertisement.includeTxPower) 'Includes': DBusArray.string(['tx-power']),
      if (discoverable != null) 'Discoverable': DBusBoolean(discoverable),
    };
  }

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
  Future<DBusMethodResponse> doRelease() async {
    onRelease();
    return DBusMethodSuccessResponse();
  }
}
