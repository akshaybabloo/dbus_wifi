// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object ./interfaces/org.freedesktop.NetworkManager.Settings.xml

import 'dart:io';
import 'package:dbus/dbus.dart';

/// Signal data for org.freedesktop.NetworkManager.Settings.Connection.Updated.
class OrgFreedesktopNetworkManagerSettingsUpdated extends DBusSignal {
  OrgFreedesktopNetworkManagerSettingsUpdated(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.freedesktop.NetworkManager.Settings.Connection.Removed.
class OrgFreedesktopNetworkManagerSettingsRemoved extends DBusSignal {
  OrgFreedesktopNetworkManagerSettingsRemoved(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

class OrgFreedesktopNetworkManagerSettings extends DBusRemoteObject {
  /// Stream of org.freedesktop.NetworkManager.Settings.Connection.Updated signals.
  late final Stream<OrgFreedesktopNetworkManagerSettingsUpdated> updated;

  /// Stream of org.freedesktop.NetworkManager.Settings.Connection.Removed signals.
  late final Stream<OrgFreedesktopNetworkManagerSettingsRemoved> removed;

  OrgFreedesktopNetworkManagerSettings(DBusClient client, String destination, {DBusObjectPath path = const DBusObjectPath.unchecked('/org/freedesktop/NetworkManager/Settings')}) : super(client, name: destination, path: path) {
    updated = DBusRemoteObjectSignalStream(object: this, interface: 'org.freedesktop.NetworkManager.Settings.Connection', name: 'Updated', signature: DBusSignature('')).asBroadcastStream().map((signal) => OrgFreedesktopNetworkManagerSettingsUpdated(signal));

    removed = DBusRemoteObjectSignalStream(object: this, interface: 'org.freedesktop.NetworkManager.Settings.Connection', name: 'Removed', signature: DBusSignature('')).asBroadcastStream().map((signal) => OrgFreedesktopNetworkManagerSettingsRemoved(signal));
  }

  /// Invokes org.freedesktop.NetworkManager.Settings.ListConnections()
  Future<List<DBusObjectPath>> callListConnections({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.NetworkManager.Settings', 'ListConnections', [], replySignature: DBusSignature('ao'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asObjectPathArray().toList();
  }

  /// Invokes org.freedesktop.NetworkManager.Settings.GetConnectionByUuid()
  Future<DBusObjectPath> callGetConnectionByUuid(String uuid, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.NetworkManager.Settings', 'GetConnectionByUuid', [DBusString(uuid)], replySignature: DBusSignature('o'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asObjectPath();
  }

  /// Invokes org.freedesktop.NetworkManager.Settings.AddConnection()
  Future<DBusObjectPath> callAddConnection(Map<String, Map<String, DBusValue>> connection, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.NetworkManager.Settings', 'AddConnection', [DBusDict(DBusSignature('s'), DBusSignature('a{sv}'), connection.map((key, value) => MapEntry(DBusString(key), DBusDict.stringVariant(value))))], replySignature: DBusSignature('o'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asObjectPath();
  }

  /// Invokes org.freedesktop.NetworkManager.Settings.SaveHostname()
  Future<void> callSaveHostname(String hostname, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.NetworkManager.Settings', 'SaveHostname', [DBusString(hostname)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.NetworkManager.Settings.Connection.Update()
  Future<void> callUpdate(Map<String, Map<String, DBusValue>> properties, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.NetworkManager.Settings.Connection', 'Update', [DBusDict(DBusSignature('s'), DBusSignature('a{sv}'), properties.map((key, value) => MapEntry(DBusString(key), DBusDict.stringVariant(value))))], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.NetworkManager.Settings.Connection.Delete()
  Future<void> callDelete({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.NetworkManager.Settings.Connection', 'Delete', [], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.NetworkManager.Settings.Connection.GetSettings()
  Future<Map<String, Map<String, DBusValue>>> callGetSettings({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.NetworkManager.Settings.Connection', 'GetSettings', [], replySignature: DBusSignature('a{sa{sv}}'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asDict().map((key, value) => MapEntry(key.asString(), value.asStringVariantDict()));
  }
}
