// This file was generated using the following command and may be overwritten.
// dart-dbus generate-object ./interfaces/org.bluez.LEAdvertisement1.xml

import 'dart:io';
import 'package:dbus/dbus.dart';

class OrgBluezLEAdvertisement1 extends DBusObject {
  /// Creates a new object to expose on [path].
  OrgBluezLEAdvertisement1({DBusObjectPath path = const DBusObjectPath.unchecked('/')}) : super(path);

  /// Gets value of property org.bluez.LEAdvertisement1.Type
  Future<DBusMethodResponse> getType() async {
    return DBusMethodErrorResponse.failed('Get org.bluez.LEAdvertisement1.Type not implemented');
  }

  /// Gets value of property org.bluez.LEAdvertisement1.ServiceUUIDs
  Future<DBusMethodResponse> getServiceUUIDs() async {
    return DBusMethodErrorResponse.failed('Get org.bluez.LEAdvertisement1.ServiceUUIDs not implemented');
  }

  /// Gets value of property org.bluez.LEAdvertisement1.ManufacturerData
  Future<DBusMethodResponse> getManufacturerData() async {
    return DBusMethodErrorResponse.failed('Get org.bluez.LEAdvertisement1.ManufacturerData not implemented');
  }

  /// Gets value of property org.bluez.LEAdvertisement1.ServiceData
  Future<DBusMethodResponse> getServiceData() async {
    return DBusMethodErrorResponse.failed('Get org.bluez.LEAdvertisement1.ServiceData not implemented');
  }

  /// Gets value of property org.bluez.LEAdvertisement1.LocalName
  Future<DBusMethodResponse> getLocalName() async {
    return DBusMethodErrorResponse.failed('Get org.bluez.LEAdvertisement1.LocalName not implemented');
  }

  /// Gets value of property org.bluez.LEAdvertisement1.Includes
  Future<DBusMethodResponse> getIncludes() async {
    return DBusMethodErrorResponse.failed('Get org.bluez.LEAdvertisement1.Includes not implemented');
  }

  /// Gets value of property org.bluez.LEAdvertisement1.Discoverable
  Future<DBusMethodResponse> getDiscoverable() async {
    return DBusMethodErrorResponse.failed('Get org.bluez.LEAdvertisement1.Discoverable not implemented');
  }

  /// Implementation of org.bluez.LEAdvertisement1.Release()
  Future<DBusMethodResponse> doRelease() async {
    return DBusMethodErrorResponse.failed('org.bluez.LEAdvertisement1.Release() not implemented');
  }

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface('org.bluez.LEAdvertisement1', methods: [
        DBusIntrospectMethod('Release')
      ], properties: [
        DBusIntrospectProperty('Type', DBusSignature('s'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('ServiceUUIDs', DBusSignature('as'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('ManufacturerData', DBusSignature('a{qv}'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('ServiceData', DBusSignature('a{sv}'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('LocalName', DBusSignature('s'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Includes', DBusSignature('as'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Discoverable', DBusSignature('b'), access: DBusPropertyAccess.read)
      ])
    ];
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface == 'org.bluez.LEAdvertisement1') {
      if (methodCall.name == 'Release') {
        if (methodCall.values.isNotEmpty) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doRelease();
      } else {
        return DBusMethodErrorResponse.unknownMethod();
      }
    } else {
      return DBusMethodErrorResponse.unknownInterface();
    }
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    if (interface == 'org.bluez.LEAdvertisement1') {
      if (name == 'Type') {
        return getType();
      } else if (name == 'ServiceUUIDs') {
        return getServiceUUIDs();
      } else if (name == 'ManufacturerData') {
        return getManufacturerData();
      } else if (name == 'ServiceData') {
        return getServiceData();
      } else if (name == 'LocalName') {
        return getLocalName();
      } else if (name == 'Includes') {
        return getIncludes();
      } else if (name == 'Discoverable') {
        return getDiscoverable();
      } else {
        return DBusMethodErrorResponse.unknownProperty();
      }
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }

  @override
  Future<DBusMethodResponse> setProperty(String interface, String name, DBusValue value) async {
    if (interface == 'org.bluez.LEAdvertisement1') {
      if (name == 'Type') {
        return DBusMethodErrorResponse.propertyReadOnly();
      } else if (name == 'ServiceUUIDs') {
        return DBusMethodErrorResponse.propertyReadOnly();
      } else if (name == 'ManufacturerData') {
        return DBusMethodErrorResponse.propertyReadOnly();
      } else if (name == 'ServiceData') {
        return DBusMethodErrorResponse.propertyReadOnly();
      } else if (name == 'LocalName') {
        return DBusMethodErrorResponse.propertyReadOnly();
      } else if (name == 'Includes') {
        return DBusMethodErrorResponse.propertyReadOnly();
      } else if (name == 'Discoverable') {
        return DBusMethodErrorResponse.propertyReadOnly();
      } else {
        return DBusMethodErrorResponse.unknownProperty();
      }
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }

  @override
  Future<DBusMethodResponse> getAllProperties(String interface) async {
    var properties = <String, DBusValue>{};
    if (interface == 'org.bluez.LEAdvertisement1') {
      properties['Type'] = (await getType()).returnValues[0];
      properties['ServiceUUIDs'] = (await getServiceUUIDs()).returnValues[0];
      properties['ManufacturerData'] = (await getManufacturerData()).returnValues[0];
      properties['ServiceData'] = (await getServiceData()).returnValues[0];
      properties['LocalName'] = (await getLocalName()).returnValues[0];
      properties['Includes'] = (await getIncludes()).returnValues[0];
      properties['Discoverable'] = (await getDiscoverable()).returnValues[0];
    }
    return DBusMethodSuccessResponse([DBusDict.stringVariant(properties)]);
  }
}
