import 'dart:io';
import 'dart:typed_data';

import 'package:dart_console/dart_console.dart';
import 'package:dbus_wifi/dbus_bluetooth.dart';

const echoServiceUuid = '12345678-1234-5678-1234-56789abcdef0';
const echoCharacteristicUuid = '12345678-1234-5678-1234-56789abcdef1';

void main() async {
  final bluetooth = DbusBluetooth();
  final console = Console();

  if (!await bluetooth.hasAdapter) {
    console.writeLine('No Bluetooth adapter found.');
    await bluetooth.close();
    return;
  }

  printMenu(console);
  var option = int.tryParse(console.readLine() ?? '');

  while (option != 7) {
    try {
      switch (option) {
        case 1:
          await adapterStatus(bluetooth, console);
          break;
        case 2:
          await togglePower(bluetooth, console);
          break;
        case 3:
          await setName(bluetooth, console);
          break;
        case 4:
          await scanForDevices(bluetooth, console);
          break;
        case 5:
          await listConnectedDevices(bluetooth, console);
          break;
        case 6:
          await runEchoPeripheral(bluetooth, console);
          break;
        default:
          console.writeLine('Invalid option. Please try again.');
      }
    } catch (e) {
      console.writeLine('Failed: $e');
    }

    console.writeLine('');
    printMenu(console);
    option = int.tryParse(console.readLine() ?? '');
  }

  await bluetooth.close();
}

void printMenu(Console console) {
  console.writeLine('Bluetooth Manager');
  console.writeLine('-----------------');
  console.writeLine('1. Adapter status');
  console.writeLine('2. Toggle adapter power');
  console.writeLine('3. Set adapter name');
  console.writeLine('4. Scan for devices');
  console.writeLine('5. List connected devices');
  console.writeLine('6. Run echo peripheral');
  console.writeLine('7. Exit');
  console.writeLine('');
  console.writeLine('Select an option:');
}

/// Shows the adapter's name, address and power state
Future<void> adapterStatus(DbusBluetooth bluetooth, Console console) async {
  console.writeLine('Adapter: ${(await bluetooth.adapterPath).value}');
  console.writeLine('Name: ${await bluetooth.alias}');
  console.writeLine('Address: ${await bluetooth.address}');
  console.writeLine('Powered: ${await bluetooth.isPowered ? 'on' : 'off'}');
}

/// Powers the adapter on or off
Future<void> togglePower(DbusBluetooth bluetooth, Console console) async {
  final currentState = await bluetooth.isPowered;
  console.writeLine('The adapter is currently ${currentState ? 'on' : 'off'}.');
  console.writeLine('Turn it ${currentState ? 'off' : 'on'}? (y/n)');

  final input = console.readLine();
  if (input == null || input.toLowerCase() != 'y') {
    console.writeLine('Operation cancelled.');
    return;
  }

  final newState = await bluetooth.setPowered(!currentState);
  console.writeLine('The adapter is now ${newState ? 'on' : 'off'}.');
}

/// Sets the adapter's friendly name
Future<void> setName(DbusBluetooth bluetooth, Console console) async {
  console.writeLine('Current name: ${await bluetooth.alias}');
  console.writeLine('Enter a new name (or leave empty to cancel):');

  final input = console.readLine();
  if (input == null || input.trim().isEmpty) {
    console.writeLine('Operation cancelled.');
    return;
  }

  await bluetooth.setAlias(input.trim());
  console.writeLine('The adapter is now named "${await bluetooth.alias}".');
}

/// Scans for nearby Bluetooth LE devices
Future<void> scanForDevices(DbusBluetooth bluetooth, Console console) async {
  console.writeLine('Scanning for devices...');
  final devices = await bluetooth.scan(timeout: Duration(seconds: 7));
  console.writeLine('Found ${devices.length} devices:\n');
  if (devices.isEmpty) {
    return;
  }

  final table = Table()
    ..insertColumn(header: 'ID', alignment: TextAlignment.center)
    ..insertColumn(header: 'Name', alignment: TextAlignment.left)
    ..insertColumn(header: 'Address', alignment: TextAlignment.left)
    ..insertColumn(header: 'RSSI', alignment: TextAlignment.right)
    ..insertColumn(header: 'Connected', alignment: TextAlignment.center);
  for (final (i, device) in devices.indexed) {
    table.insertRow(
        [i + 1, device.name ?? 'Unknown', device.address, '${device.rssi} dBm', device.connected ? 'yes' : 'no']);
  }
  console.write(table.render());
}

/// Lists devices currently connected to the adapter
Future<void> listConnectedDevices(DbusBluetooth bluetooth, Console console) async {
  final devices = await bluetooth.connectedDevices;
  if (devices.isEmpty) {
    console.writeLine('No connected devices.');
    return;
  }

  final table = Table()
    ..insertColumn(header: 'ID', alignment: TextAlignment.center)
    ..insertColumn(header: 'Name', alignment: TextAlignment.left)
    ..insertColumn(header: 'Address', alignment: TextAlignment.left);
  for (final (i, device) in devices.indexed) {
    table.insertRow([i + 1, device.name ?? 'Unknown', device.address]);
  }
  console.write(table.render());
}

/// Advertises a service whose characteristic echoes every write back as a notification, until Ctrl+C
Future<void> runEchoPeripheral(DbusBluetooth bluetooth, Console console) async {
  if (!await bluetooth.isPowered) {
    console.writeLine('The adapter is off. Turn it on first.');
    return;
  }

  final peripheral = BlePeripheral(bluetooth);
  late final BleGattCharacteristic echo;
  echo = BleGattCharacteristic(
    uuid: echoCharacteristicUuid,
    flags: {BleCharacteristicFlag.read, BleCharacteristicFlag.write, BleCharacteristicFlag.notify},
    initialValue: Uint8List.fromList('hello'.codeUnits),
    onWrite: (value, request) async {
      console.writeLine('Received from ${request.device}: ${String.fromCharCodes(value)}');
      await peripheral.notify(echo, value);
    },
  );

  final subscriptions = peripheral.subscriptions.listen(
    (s) => console.writeLine('Notifications ${s.notifying ? 'on' : 'off'}'),
  );
  final released = peripheral.released.listen((_) => console.writeLine('Advertisement released by BlueZ'));
  final connections = bluetooth.connectionChanges.listen(
    (device) => console.writeLine('${device.address} ${device.connected ? 'connected' : 'disconnected'}'),
  );

  try {
    await peripheral.start(
      services: [
        BleGattService(uuid: echoServiceUuid, characteristics: [echo]),
      ],
      advertisement: const BleAdvertisement(localName: 'dbus-wifi-echo', serviceUuids: [echoServiceUuid]),
    );
    console.writeLine('Advertising as "dbus-wifi-echo" with service $echoServiceUuid.');
    console.writeLine('Connect with a BLE scanner app, subscribe and write to the characteristic.');
    console.writeLine('Press Ctrl+C to stop and return to the menu.');

    await ProcessSignal.sigint.watch().first;
  } finally {
    await connections.cancel();
    await released.cancel();
    await subscriptions.cancel();
    await peripheral.dispose();
    console.writeLine('Echo peripheral stopped.');
  }
}
