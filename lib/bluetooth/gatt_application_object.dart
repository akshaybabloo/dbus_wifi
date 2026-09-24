import 'package:dbus/dbus.dart';
import 'package:dbus_wifi/interfaces/object_manager_object.dart';

/// The root of a GATT application, answering `GetManagedObjects` with only its own services and characteristics
///
/// The dbus package's built-in object manager reports every object on the connection, which would leak the
/// advertisement and any unrelated objects the host exports into the GATT database.
class GattApplicationObject extends OrgFreedesktopDBusObjectManager {
  final List<DBusObject> children = [];

  GattApplicationObject({required super.path});

  @override
  Future<DBusMethodResponse> doGetManagedObjects() async {
    return DBusMethodSuccessResponse([
      DBusDict(DBusSignature('o'), DBusSignature('a{sa{sv}}'), {
        for (final child in children)
          child.path: DBusDict(DBusSignature('s'), DBusSignature('a{sv}'), {
            for (final MapEntry(key: interface, value: properties) in child.interfacesAndProperties.entries)
              DBusString(interface): DBusDict.stringVariant(properties),
          }),
      }),
    ]);
  }
}
