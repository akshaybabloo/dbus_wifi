// This file was generated using the following command and may be overwritten.
// dart-dbus generate-object ./interfaces/org.freedesktop.DBus.ObjectManager.xml

import 'dart:io';
import 'package:dbus/dbus.dart';

class OrgFreedesktopDBusObjectManager extends DBusObject {
  /// Creates a new object to expose on [path].
  OrgFreedesktopDBusObjectManager({DBusObjectPath path = const DBusObjectPath.unchecked('/')}) : super(path);

  /// Implementation of org.freedesktop.DBus.ObjectManager.GetManagedObjects()
  Future<DBusMethodResponse> doGetManagedObjects() async {
    return DBusMethodErrorResponse.failed('org.freedesktop.DBus.ObjectManager.GetManagedObjects() not implemented');
  }

  /// Emits signal org.freedesktop.DBus.ObjectManager.InterfacesAdded
  Future<void> emitInterfacesAdded_(
      DBusObjectPath object_path, Map<String, Map<String, DBusValue>> interfaces_and_properties) async {
    await emitSignal('org.freedesktop.DBus.ObjectManager', 'InterfacesAdded', [
      object_path,
      DBusDict(DBusSignature('s'), DBusSignature('a{sv}'),
          interfaces_and_properties.map((key, value) => MapEntry(DBusString(key), DBusDict.stringVariant(value))))
    ]);
  }

  /// Emits signal org.freedesktop.DBus.ObjectManager.InterfacesRemoved
  Future<void> emitInterfacesRemoved_(DBusObjectPath object_path, List<String> interfaces) async {
    await emitSignal(
        'org.freedesktop.DBus.ObjectManager', 'InterfacesRemoved', [object_path, DBusArray.string(interfaces)]);
  }

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface('org.freedesktop.DBus.ObjectManager', methods: [
        DBusIntrospectMethod('GetManagedObjects', args: [
          DBusIntrospectArgument(DBusSignature('a{oa{sa{sv}}}'), DBusArgumentDirection.out,
              name: 'objpath_interfaces_and_properties')
        ])
      ], signals: [
        DBusIntrospectSignal('InterfacesAdded', args: [
          DBusIntrospectArgument(DBusSignature('o'), DBusArgumentDirection.out, name: 'object_path'),
          DBusIntrospectArgument(DBusSignature('a{sa{sv}}'), DBusArgumentDirection.out,
              name: 'interfaces_and_properties')
        ]),
        DBusIntrospectSignal('InterfacesRemoved', args: [
          DBusIntrospectArgument(DBusSignature('o'), DBusArgumentDirection.out, name: 'object_path'),
          DBusIntrospectArgument(DBusSignature('as'), DBusArgumentDirection.out, name: 'interfaces')
        ])
      ])
    ];
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface == 'org.freedesktop.DBus.ObjectManager') {
      if (methodCall.name == 'GetManagedObjects') {
        if (methodCall.values.isNotEmpty) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doGetManagedObjects();
      } else {
        return DBusMethodErrorResponse.unknownMethod();
      }
    } else {
      return DBusMethodErrorResponse.unknownInterface();
    }
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    if (interface == 'org.freedesktop.DBus.ObjectManager') {
      return DBusMethodErrorResponse.unknownProperty();
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }

  @override
  Future<DBusMethodResponse> setProperty(String interface, String name, DBusValue value) async {
    if (interface == 'org.freedesktop.DBus.ObjectManager') {
      return DBusMethodErrorResponse.unknownProperty();
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }
}
