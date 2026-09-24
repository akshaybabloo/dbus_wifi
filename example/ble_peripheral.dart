import 'dart:io';
import 'dart:typed_data';

import 'package:dbus_wifi/dbus_bluetooth.dart';

const serviceUuid = '12345678-1234-5678-1234-56789abcdef0';
const echoUuid = '12345678-1234-5678-1234-56789abcdef1';

/// Advertises as "dbus-wifi-echo" with one characteristic that echoes every write back as a notification.
/// Connect with a BLE scanner app such as nRF Connect, subscribe, then write to it. Press Ctrl+C to stop.
void main() async {
  final bluetooth = DbusBluetooth();
  if (!await bluetooth.hasAdapter) {
    print('No Bluetooth adapter found.');
    await bluetooth.close();
    return;
  }
  if (!await bluetooth.isPowered) {
    await bluetooth.setPowered(true);
  }

  final peripheral = BlePeripheral(bluetooth);
  late final BleGattCharacteristic echo;
  echo = BleGattCharacteristic(
    uuid: echoUuid,
    flags: {BleCharacteristicFlag.read, BleCharacteristicFlag.write, BleCharacteristicFlag.notify},
    initialValue: Uint8List.fromList('hello'.codeUnits),
    onWrite: (value, request) async {
      print('Write from ${request.device} (MTU ${request.mtu}): ${String.fromCharCodes(value)}');
      await peripheral.notify(echo, value);
    },
  );

  peripheral.subscriptions.listen((s) => print('Notifications ${s.notifying ? 'on' : 'off'}'));
  peripheral.released.listen((_) => print('Advertisement released by BlueZ'));
  final connections = bluetooth.connectionChanges.listen(
    (device) => print('${device.address} ${device.connected ? 'connected' : 'disconnected'}'),
  );

  await peripheral.start(
    services: [
      BleGattService(uuid: serviceUuid, characteristics: [echo]),
    ],
    advertisement: const BleAdvertisement(localName: 'dbus-wifi-echo', serviceUuids: [serviceUuid]),
  );
  print('Advertising on ${await bluetooth.address}. Press Ctrl+C to stop.');

  await ProcessSignal.sigint.watch().first;
  await connections.cancel();
  await peripheral.dispose();
  await bluetooth.close();
}
