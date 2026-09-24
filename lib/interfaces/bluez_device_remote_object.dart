// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object ./interfaces/org.bluez.Device1.xml

import 'dart:io';
import 'package:dbus/dbus.dart';

class OrgBluezDevice1 extends DBusRemoteObject {
  OrgBluezDevice1(DBusClient client, String destination, DBusObjectPath path)
      : super(client, name: destination, path: path);

  /// Gets org.bluez.Device1.Address
  Future<String> getAddress() async {
    var value = await getProperty('org.bluez.Device1', 'Address', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Gets org.bluez.Device1.AddressType
  Future<String> getAddressType() async {
    var value = await getProperty('org.bluez.Device1', 'AddressType', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Gets org.bluez.Device1.Name
  Future<String> getName() async {
    var value = await getProperty('org.bluez.Device1', 'Name', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Gets org.bluez.Device1.Alias
  Future<String> getAlias() async {
    var value = await getProperty('org.bluez.Device1', 'Alias', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Sets org.bluez.Device1.Alias
  Future<void> setAlias(String value) async {
    await setProperty('org.bluez.Device1', 'Alias', DBusString(value));
  }

  /// Gets org.bluez.Device1.Paired
  Future<bool> getPaired() async {
    var value = await getProperty('org.bluez.Device1', 'Paired', signature: DBusSignature('b'));
    return value.asBoolean();
  }

  /// Gets org.bluez.Device1.Trusted
  Future<bool> getTrusted() async {
    var value = await getProperty('org.bluez.Device1', 'Trusted', signature: DBusSignature('b'));
    return value.asBoolean();
  }

  /// Sets org.bluez.Device1.Trusted
  Future<void> setTrusted(bool value) async {
    await setProperty('org.bluez.Device1', 'Trusted', DBusBoolean(value));
  }

  /// Gets org.bluez.Device1.Blocked
  Future<bool> getBlocked() async {
    var value = await getProperty('org.bluez.Device1', 'Blocked', signature: DBusSignature('b'));
    return value.asBoolean();
  }

  /// Sets org.bluez.Device1.Blocked
  Future<void> setBlocked(bool value) async {
    await setProperty('org.bluez.Device1', 'Blocked', DBusBoolean(value));
  }

  /// Gets org.bluez.Device1.Connected
  Future<bool> getConnected() async {
    var value = await getProperty('org.bluez.Device1', 'Connected', signature: DBusSignature('b'));
    return value.asBoolean();
  }

  /// Gets org.bluez.Device1.RSSI
  Future<int> getRSSI() async {
    var value = await getProperty('org.bluez.Device1', 'RSSI', signature: DBusSignature('n'));
    return value.asInt16();
  }

  /// Gets org.bluez.Device1.UUIDs
  Future<List<String>> getUUIDs() async {
    var value = await getProperty('org.bluez.Device1', 'UUIDs', signature: DBusSignature('as'));
    return value.asStringArray().toList();
  }

  /// Gets org.bluez.Device1.Adapter
  Future<DBusObjectPath> getAdapter() async {
    var value = await getProperty('org.bluez.Device1', 'Adapter', signature: DBusSignature('o'));
    return value.asObjectPath();
  }

  /// Gets org.bluez.Device1.ServicesResolved
  Future<bool> getServicesResolved() async {
    var value = await getProperty('org.bluez.Device1', 'ServicesResolved', signature: DBusSignature('b'));
    return value.asBoolean();
  }

  /// Invokes org.bluez.Device1.Connect()
  Future<void> callConnect({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.bluez.Device1', 'Connect', [],
        replySignature: DBusSignature(''),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.bluez.Device1.Disconnect()
  Future<void> callDisconnect({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.bluez.Device1', 'Disconnect', [],
        replySignature: DBusSignature(''),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
  }
}
