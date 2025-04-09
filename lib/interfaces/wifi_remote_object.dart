// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object ./interfaces/org.freedesktop.NetworkManager.xml

import 'dart:io';
import 'package:dbus/dbus.dart';

class OrgFreedesktopNetworkManager extends DBusRemoteObject {
  OrgFreedesktopNetworkManager(DBusClient client, String destination, {DBusObjectPath path = const DBusObjectPath.unchecked('/org/freedesktop/NetworkManager')}) : super(client, name: destination, path: path);

  /// Gets org.freedesktop.NetworkManager.AllDevices
  Future<List<DBusObjectPath>> getAllDevices() async {
    var value = await getProperty('org.freedesktop.NetworkManager', 'AllDevices', signature: DBusSignature('ao'));
    return value.asObjectPathArray().toList();
  }

  /// Gets org.freedesktop.NetworkManager.WirelessEnabled
  Future<bool> getWirelessEnabled() async {
    var value = await getProperty('org.freedesktop.NetworkManager', 'WirelessEnabled', signature: DBusSignature('b'));
    return value.asBoolean();
  }

  /// Sets org.freedesktop.NetworkManager.WirelessEnabled
  Future<void> setWirelessEnabled (bool value) async {
    await setProperty('org.freedesktop.NetworkManager', 'WirelessEnabled', DBusBoolean(value));
  }

  /// Invokes org.freedesktop.NetworkManager.GetAllDevices()
  Future<List<DBusObjectPath>> callGetAllDevices({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.NetworkManager', 'GetAllDevices', [], replySignature: DBusSignature('ao'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asObjectPathArray().toList();
  }

  /// Invokes org.freedesktop.NetworkManager.AddAndActivateConnection()
  Future<List<DBusValue>> callAddAndActivateConnection(Map<String, Map<String, DBusValue>> connection, DBusObjectPath device, DBusObjectPath specificObject, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.NetworkManager', 'AddAndActivateConnection', [DBusDict(DBusSignature('s'), DBusSignature('a{sv}'), connection.map((key, value) => MapEntry(DBusString(key), DBusDict.stringVariant(value)))), device, specificObject], replySignature: DBusSignature('oo'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues;
  }

  /// Gets org.freedesktop.NetworkManager.Device.DeviceType
  Future<int> getDeviceType() async {
    var value = await getProperty('org.freedesktop.NetworkManager.Device', 'DeviceType', signature: DBusSignature('u'));
    return value.asUint32();
  }

  /// Gets org.freedesktop.NetworkManager.Device.Wireless.AccessPoints
  Future<List<DBusObjectPath>> getAccessPoints() async {
    var value = await getProperty('org.freedesktop.NetworkManager.Device.Wireless', 'AccessPoints', signature: DBusSignature('ao'));
    return value.asObjectPathArray().toList();
  }

  /// Gets org.freedesktop.NetworkManager.Device.Wireless.ActiveAccessPoint
  Future<DBusObjectPath> getActiveAccessPoint() async {
    var value = await getProperty('org.freedesktop.NetworkManager.Device.Wireless', 'ActiveAccessPoint', signature: DBusSignature('o'));
    return value.asObjectPath();
  }

  /// Gets org.freedesktop.NetworkManager.Device.Wireless.Mode
  Future<int> getMode() async {
    var value = await getProperty('org.freedesktop.NetworkManager.Device.Wireless', 'Mode', signature: DBusSignature('u'));
    return value.asUint32();
  }

  /// Invokes org.freedesktop.NetworkManager.Device.Wireless.GetAllAccessPoints()
  Future<List<DBusObjectPath>> callGetAllAccessPoints({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.NetworkManager.Device.Wireless', 'GetAllAccessPoints', [], replySignature: DBusSignature('ao'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asObjectPathArray().toList();
  }

  /// Invokes org.freedesktop.NetworkManager.Device.Wireless.RequestScan()
  Future<void> callRequestScan(Map<String, DBusValue> options, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.NetworkManager.Device.Wireless', 'RequestScan', [DBusDict.stringVariant(options)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Gets org.freedesktop.NetworkManager.AccessPoint.Ssid
  Future<List<int>> getSsid() async {
    var value = await getProperty('org.freedesktop.NetworkManager.AccessPoint', 'Ssid', signature: DBusSignature('ay'));
    return value.asByteArray().toList();
  }

  /// Gets org.freedesktop.NetworkManager.AccessPoint.HwAddress
  Future<String> getHwAddress() async {
    var value = await getProperty('org.freedesktop.NetworkManager.AccessPoint', 'HwAddress', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Gets org.freedesktop.NetworkManager.AccessPoint.Strength
  Future<int> getStrength() async {
    var value = await getProperty('org.freedesktop.NetworkManager.AccessPoint', 'Strength', signature: DBusSignature('y'));
    return value.asByte();
  }

  /// Gets org.freedesktop.NetworkManager.AccessPoint.Flags
  Future<int> getFlags() async {
    var value = await getProperty('org.freedesktop.NetworkManager.AccessPoint', 'Flags', signature: DBusSignature('u'));
    return value.asUint32();
  }

  /// Gets org.freedesktop.NetworkManager.AccessPoint.WpaFlags
  Future<int> getWpaFlags() async {
    var value = await getProperty('org.freedesktop.NetworkManager.AccessPoint', 'WpaFlags', signature: DBusSignature('u'));
    return value.asUint32();
  }

  /// Gets org.freedesktop.NetworkManager.AccessPoint.RsnFlags
  Future<int> getRsnFlags() async {
    var value = await getProperty('org.freedesktop.NetworkManager.AccessPoint', 'RsnFlags', signature: DBusSignature('u'));
    return value.asUint32();
  }

  /// Gets org.freedesktop.NetworkManager.AccessPoint.LastSeen
  Future<int> getLastSeen() async {
    var value = await getProperty('org.freedesktop.NetworkManager.AccessPoint', 'LastSeen', signature: DBusSignature('i'));
    return value.asInt32();
  }

  /// Gets org.freedesktop.NetworkManager.AccessPoint.Mode
  Future<int> getMode_() async {
    var value = await getProperty('org.freedesktop.NetworkManager.AccessPoint', 'Mode', signature: DBusSignature('u'));
    return value.asUint32();
  }
}
