// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object ./interfaces/org.bluez.GattManager1.xml

import 'dart:io';
import 'package:dbus/dbus.dart';

class OrgBluezGattManager1 extends DBusRemoteObject {
  OrgBluezGattManager1(DBusClient client, String destination, DBusObjectPath path)
      : super(client, name: destination, path: path);

  /// Invokes org.bluez.GattManager1.RegisterApplication()
  Future<void> callRegisterApplication(DBusObjectPath application, Map<String, DBusValue> options,
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.bluez.GattManager1', 'RegisterApplication', [application, DBusDict.stringVariant(options)],
        replySignature: DBusSignature(''),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.bluez.GattManager1.UnregisterApplication()
  Future<void> callUnregisterApplication(DBusObjectPath application,
      {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.bluez.GattManager1', 'UnregisterApplication', [application],
        replySignature: DBusSignature(''),
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization);
  }
}
