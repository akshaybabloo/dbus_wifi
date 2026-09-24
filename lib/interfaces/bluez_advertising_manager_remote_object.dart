// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object ./interfaces/org.bluez.LEAdvertisingManager1.xml

import 'dart:io';
import 'package:dbus/dbus.dart';

class OrgBluezLEAdvertisingManager1 extends DBusRemoteObject {
  OrgBluezLEAdvertisingManager1(DBusClient client, String destination, DBusObjectPath path)
      : super(client, name: destination, path: path);

  /// Gets org.bluez.LEAdvertisingManager1.ActiveInstances
  Future<int> getActiveInstances() async {
    var value = await getProperty('org.bluez.LEAdvertisingManager1', 'ActiveInstances', signature: DBusSignature('y'));
    return value.asByte();
  }

  /// Gets org.bluez.LEAdvertisingManager1.SupportedInstances
  Future<int> getSupportedInstances() async {
    var value =
        await getProperty('org.bluez.LEAdvertisingManager1', 'SupportedInstances', signature: DBusSignature('y'));
    return value.asByte();
  }

  /// Gets org.bluez.LEAdvertisingManager1.SupportedIncludes
  Future<List<String>> getSupportedIncludes() async {
    var value =
        await getProperty('org.bluez.LEAdvertisingManager1', 'SupportedIncludes', signature: DBusSignature('as'));
    return value.asStringArray().toList();
  }

  /// Gets org.bluez.LEAdvertisingManager1.SupportedSecondaryChannels
  Future<List<String>> getSupportedSecondaryChannels() async {
    var value = await getProperty('org.bluez.LEAdvertisingManager1', 'SupportedSecondaryChannels',
        signature: DBusSignature('as'));
    return value.asStringArray().toList();
  }

  /// Invokes org.bluez.LEAdvertisingManager1.RegisterAdvertisement()
  Future<void> callRegisterAdvertisement(DBusObjectPath advertisement, Map<String, DBusValue> options,
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod(
        'org.bluez.LEAdvertisingManager1', 'RegisterAdvertisement', [advertisement, DBusDict.stringVariant(options)],
        replySignature: DBusSignature(''),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.bluez.LEAdvertisingManager1.UnregisterAdvertisement()
  Future<void> callUnregisterAdvertisement(DBusObjectPath service,
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.bluez.LEAdvertisingManager1', 'UnregisterAdvertisement', [service],
        replySignature: DBusSignature(''),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
  }
}
