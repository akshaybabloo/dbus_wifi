// This file was generated using the following command and may be overwritten.
// dart-dbus generate-object ./interfaces/org.bluez.GattCharacteristic1.xml

import 'dart:io';
import 'package:dbus/dbus.dart';

class OrgBluezGattCharacteristic1 extends DBusObject {
  /// Creates a new object to expose on [path].
  OrgBluezGattCharacteristic1({DBusObjectPath path = const DBusObjectPath.unchecked('/')}) : super(path);

  /// Gets value of property org.bluez.GattCharacteristic1.UUID
  Future<DBusMethodResponse> getUUID() async {
    return DBusMethodErrorResponse.failed('Get org.bluez.GattCharacteristic1.UUID not implemented');
  }

  /// Gets value of property org.bluez.GattCharacteristic1.Service
  Future<DBusMethodResponse> getService() async {
    return DBusMethodErrorResponse.failed('Get org.bluez.GattCharacteristic1.Service not implemented');
  }

  /// Gets value of property org.bluez.GattCharacteristic1.Value
  Future<DBusMethodResponse> getValue() async {
    return DBusMethodErrorResponse.failed('Get org.bluez.GattCharacteristic1.Value not implemented');
  }

  /// Gets value of property org.bluez.GattCharacteristic1.Notifying
  Future<DBusMethodResponse> getNotifying() async {
    return DBusMethodErrorResponse.failed('Get org.bluez.GattCharacteristic1.Notifying not implemented');
  }

  /// Gets value of property org.bluez.GattCharacteristic1.Flags
  Future<DBusMethodResponse> getFlags() async {
    return DBusMethodErrorResponse.failed('Get org.bluez.GattCharacteristic1.Flags not implemented');
  }

  /// Implementation of org.bluez.GattCharacteristic1.ReadValue()
  Future<DBusMethodResponse> doReadValue(Map<String, DBusValue> options) async {
    return DBusMethodErrorResponse.failed('org.bluez.GattCharacteristic1.ReadValue() not implemented');
  }

  /// Implementation of org.bluez.GattCharacteristic1.WriteValue()
  Future<DBusMethodResponse> doWriteValue(List<int> value, Map<String, DBusValue> options) async {
    return DBusMethodErrorResponse.failed('org.bluez.GattCharacteristic1.WriteValue() not implemented');
  }

  /// Implementation of org.bluez.GattCharacteristic1.StartNotify()
  Future<DBusMethodResponse> doStartNotify() async {
    return DBusMethodErrorResponse.failed('org.bluez.GattCharacteristic1.StartNotify() not implemented');
  }

  /// Implementation of org.bluez.GattCharacteristic1.StopNotify()
  Future<DBusMethodResponse> doStopNotify() async {
    return DBusMethodErrorResponse.failed('org.bluez.GattCharacteristic1.StopNotify() not implemented');
  }

  /// Implementation of org.bluez.GattCharacteristic1.Confirm()
  Future<DBusMethodResponse> doConfirm() async {
    return DBusMethodErrorResponse.failed('org.bluez.GattCharacteristic1.Confirm() not implemented');
  }

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface('org.bluez.GattCharacteristic1', methods: [
        DBusIntrospectMethod('ReadValue', args: [
          DBusIntrospectArgument(DBusSignature('a{sv}'), DBusArgumentDirection.in_, name: 'options'),
          DBusIntrospectArgument(DBusSignature('ay'), DBusArgumentDirection.out, name: 'value')
        ]),
        DBusIntrospectMethod('WriteValue', args: [
          DBusIntrospectArgument(DBusSignature('ay'), DBusArgumentDirection.in_, name: 'value'),
          DBusIntrospectArgument(DBusSignature('a{sv}'), DBusArgumentDirection.in_, name: 'options')
        ]),
        DBusIntrospectMethod('StartNotify'),
        DBusIntrospectMethod('StopNotify'),
        DBusIntrospectMethod('Confirm')
      ], properties: [
        DBusIntrospectProperty('UUID', DBusSignature('s'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Service', DBusSignature('o'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Value', DBusSignature('ay'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Notifying', DBusSignature('b'), access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Flags', DBusSignature('as'), access: DBusPropertyAccess.read)
      ])
    ];
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface == 'org.bluez.GattCharacteristic1') {
      if (methodCall.name == 'ReadValue') {
        if (methodCall.signature != DBusSignature('a{sv}')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doReadValue(methodCall.values[0].asStringVariantDict());
      } else if (methodCall.name == 'WriteValue') {
        if (methodCall.signature != DBusSignature('aya{sv}')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doWriteValue(methodCall.values[0].asByteArray().toList(), methodCall.values[1].asStringVariantDict());
      } else if (methodCall.name == 'StartNotify') {
        if (methodCall.values.isNotEmpty) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doStartNotify();
      } else if (methodCall.name == 'StopNotify') {
        if (methodCall.values.isNotEmpty) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doStopNotify();
      } else if (methodCall.name == 'Confirm') {
        if (methodCall.values.isNotEmpty) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doConfirm();
      } else {
        return DBusMethodErrorResponse.unknownMethod();
      }
    } else {
      return DBusMethodErrorResponse.unknownInterface();
    }
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    if (interface == 'org.bluez.GattCharacteristic1') {
      if (name == 'UUID') {
        return getUUID();
      } else if (name == 'Service') {
        return getService();
      } else if (name == 'Value') {
        return getValue();
      } else if (name == 'Notifying') {
        return getNotifying();
      } else if (name == 'Flags') {
        return getFlags();
      } else {
        return DBusMethodErrorResponse.unknownProperty();
      }
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }

  @override
  Future<DBusMethodResponse> setProperty(String interface, String name, DBusValue value) async {
    if (interface == 'org.bluez.GattCharacteristic1') {
      if (name == 'UUID') {
        return DBusMethodErrorResponse.propertyReadOnly();
      } else if (name == 'Service') {
        return DBusMethodErrorResponse.propertyReadOnly();
      } else if (name == 'Value') {
        return DBusMethodErrorResponse.propertyReadOnly();
      } else if (name == 'Notifying') {
        return DBusMethodErrorResponse.propertyReadOnly();
      } else if (name == 'Flags') {
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
    if (interface == 'org.bluez.GattCharacteristic1') {
      properties['UUID'] = (await getUUID()).returnValues[0];
      properties['Service'] = (await getService()).returnValues[0];
      properties['Value'] = (await getValue()).returnValues[0];
      properties['Notifying'] = (await getNotifying()).returnValues[0];
      properties['Flags'] = (await getFlags()).returnValues[0];
    }
    return DBusMethodSuccessResponse([DBusDict.stringVariant(properties)]);
  }
}
