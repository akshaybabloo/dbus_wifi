// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object ./interfaces/org.bluez.Adapter1.xml

import 'dart:io';
import 'package:dbus/dbus.dart';

class OrgBluezAdapter1 extends DBusRemoteObject {
  OrgBluezAdapter1(DBusClient client, String destination, DBusObjectPath path)
      : super(client, name: destination, path: path);

  /// Gets org.bluez.Adapter1.Address
  Future<String> getAddress() async {
    var value = await getProperty('org.bluez.Adapter1', 'Address', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Gets org.bluez.Adapter1.AddressType
  Future<String> getAddressType() async {
    var value = await getProperty('org.bluez.Adapter1', 'AddressType', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Gets org.bluez.Adapter1.Name
  Future<String> getName() async {
    var value = await getProperty('org.bluez.Adapter1', 'Name', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Gets org.bluez.Adapter1.Alias
  Future<String> getAlias() async {
    var value = await getProperty('org.bluez.Adapter1', 'Alias', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Sets org.bluez.Adapter1.Alias
  Future<void> setAlias(String value) async {
    await setProperty('org.bluez.Adapter1', 'Alias', DBusString(value));
  }

  /// Gets org.bluez.Adapter1.Class
  Future<int> getClass() async {
    var value = await getProperty('org.bluez.Adapter1', 'Class', signature: DBusSignature('u'));
    return value.asUint32();
  }

  /// Gets org.bluez.Adapter1.Powered
  Future<bool> getPowered() async {
    var value = await getProperty('org.bluez.Adapter1', 'Powered', signature: DBusSignature('b'));
    return value.asBoolean();
  }

  /// Sets org.bluez.Adapter1.Powered
  Future<void> setPowered(bool value) async {
    await setProperty('org.bluez.Adapter1', 'Powered', DBusBoolean(value));
  }

  /// Gets org.bluez.Adapter1.Discoverable
  Future<bool> getDiscoverable() async {
    var value = await getProperty('org.bluez.Adapter1', 'Discoverable', signature: DBusSignature('b'));
    return value.asBoolean();
  }

  /// Sets org.bluez.Adapter1.Discoverable
  Future<void> setDiscoverable(bool value) async {
    await setProperty('org.bluez.Adapter1', 'Discoverable', DBusBoolean(value));
  }

  /// Gets org.bluez.Adapter1.DiscoverableTimeout
  Future<int> getDiscoverableTimeout() async {
    var value = await getProperty('org.bluez.Adapter1', 'DiscoverableTimeout', signature: DBusSignature('u'));
    return value.asUint32();
  }

  /// Sets org.bluez.Adapter1.DiscoverableTimeout
  Future<void> setDiscoverableTimeout(int value) async {
    await setProperty('org.bluez.Adapter1', 'DiscoverableTimeout', DBusUint32(value));
  }

  /// Gets org.bluez.Adapter1.Pairable
  Future<bool> getPairable() async {
    var value = await getProperty('org.bluez.Adapter1', 'Pairable', signature: DBusSignature('b'));
    return value.asBoolean();
  }

  /// Sets org.bluez.Adapter1.Pairable
  Future<void> setPairable(bool value) async {
    await setProperty('org.bluez.Adapter1', 'Pairable', DBusBoolean(value));
  }

  /// Gets org.bluez.Adapter1.PairableTimeout
  Future<int> getPairableTimeout() async {
    var value = await getProperty('org.bluez.Adapter1', 'PairableTimeout', signature: DBusSignature('u'));
    return value.asUint32();
  }

  /// Sets org.bluez.Adapter1.PairableTimeout
  Future<void> setPairableTimeout(int value) async {
    await setProperty('org.bluez.Adapter1', 'PairableTimeout', DBusUint32(value));
  }

  /// Gets org.bluez.Adapter1.Discovering
  Future<bool> getDiscovering() async {
    var value = await getProperty('org.bluez.Adapter1', 'Discovering', signature: DBusSignature('b'));
    return value.asBoolean();
  }

  /// Gets org.bluez.Adapter1.UUIDs
  Future<List<String>> getUUIDs() async {
    var value = await getProperty('org.bluez.Adapter1', 'UUIDs', signature: DBusSignature('as'));
    return value.asStringArray().toList();
  }

  /// Gets org.bluez.Adapter1.Modalias
  Future<String> getModalias() async {
    var value = await getProperty('org.bluez.Adapter1', 'Modalias', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Gets org.bluez.Adapter1.Roles
  Future<List<String>> getRoles() async {
    var value = await getProperty('org.bluez.Adapter1', 'Roles', signature: DBusSignature('as'));
    return value.asStringArray().toList();
  }

  /// Invokes org.bluez.Adapter1.StartDiscovery()
  Future<void> callStartDiscovery({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.bluez.Adapter1', 'StartDiscovery', [],
        replySignature: DBusSignature(''),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.bluez.Adapter1.StopDiscovery()
  Future<void> callStopDiscovery({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.bluez.Adapter1', 'StopDiscovery', [],
        replySignature: DBusSignature(''),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.bluez.Adapter1.RemoveDevice()
  Future<void> callRemoveDevice(DBusObjectPath device,
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.bluez.Adapter1', 'RemoveDevice', [device],
        replySignature: DBusSignature(''),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.bluez.Adapter1.SetDiscoveryFilter()
  Future<void> callSetDiscoveryFilter(Map<String, DBusValue> properties,
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.bluez.Adapter1', 'SetDiscoveryFilter', [DBusDict.stringVariant(properties)],
        replySignature: DBusSignature(''),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.bluez.Adapter1.GetDiscoveryFilters()
  Future<List<String>> callGetDiscoveryFilters(
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.bluez.Adapter1', 'GetDiscoveryFilters', [],
        replySignature: DBusSignature('as'),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asStringArray().toList();
  }
}
