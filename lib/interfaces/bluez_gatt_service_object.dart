// This file was generated using the following command and may be overwritten.
// dart-dbus generate-object ./interfaces/org.bluez.GattService1.xml

import 'dart:io';
import 'package:dbus/dbus.dart';

class OrgBluezGattService1 extends DBusObject {
  /// Creates a new object to expose on [path].
  OrgBluezGattService1({DBusObjectPath path = const DBusObjectPath.unchecked('/')}) : super(path);

  /// Gets value of property org.bluez.GattService1.UUID
  Future<DBusMethodResponse> getUUID() async {
    return DBusMethodErrorResponse.failed('Get org.bluez.GattService1.UUID not implemented');
  }

  /// Gets value of property org.bluez.GattService1.Primary
  Future<DBusMethodResponse> getPrimary() async {
    return DBusMethodErrorResponse.failed('Get org.bluez.GattService1.Primary not implemented');
  }

  /// Gets value of property org.bluez.GattService1.Includes
  Future<DBusMethodResponse> getIncludes() async {
    return DBusMethodErrorResponse.failed('Get org.bluez.GattService1.Includes not implemented');
  }

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface('org.bluez.GattService1', properties: [
        DBusIntrospectProperty('UUID', DBusSignature('s'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Primary', DBusSignature('b'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Includes', DBusSignature('ao'), access: DBusPropertyAccess.read)
      ])
    ];
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface == 'org.bluez.GattService1') {
      return DBusMethodErrorResponse.unknownMethod();
    } else {
      return DBusMethodErrorResponse.unknownInterface();
    }
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    if (interface == 'org.bluez.GattService1') {
      if (name == 'UUID') {
        return getUUID();
      } else if (name == 'Primary') {
        return getPrimary();
      } else if (name == 'Includes') {
        return getIncludes();
      } else {
        return DBusMethodErrorResponse.unknownProperty();
      }
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }

  @override
  Future<DBusMethodResponse> setProperty(String interface, String name, DBusValue value) async {
    if (interface == 'org.bluez.GattService1') {
      if (name == 'UUID') {
        return DBusMethodErrorResponse.propertyReadOnly();
      } else if (name == 'Primary') {
        return DBusMethodErrorResponse.propertyReadOnly();
      } else if (name == 'Includes') {
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
    if (interface == 'org.bluez.GattService1') {
      properties['UUID'] = (await getUUID()).returnValues[0];
      properties['Primary'] = (await getPrimary()).returnValues[0];
      properties['Includes'] = (await getIncludes()).returnValues[0];
    }
    return DBusMethodSuccessResponse([DBusDict.stringVariant(properties)]);
  }
}
