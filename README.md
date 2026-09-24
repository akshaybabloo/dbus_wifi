# DBus Wi-Fi

A native implementation for managing Wi-Fi networks and Bluetooth LE using D-Bus on Linux. It talks to NetworkManager to scan for networks, connect to them, check connection status and disconnect, and to BlueZ to manage the Bluetooth adapter and run a Bluetooth LE peripheral (GATT server and advertisement) that phones can connect to.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  dbus_wifi: ^0.2.0
```

Then run:

```bash
dart pub get
```

## Features

- Scan for available Wi-Fi networks
- Connect to Wi-Fi networks with password authentication
- Check current connection status
- Disconnect from networks
- View saved networks
- Forget (delete) saved networks
- Check whether Wi-Fi is enabled and toggle it on or off
- Check the Bluetooth adapter, toggle it, scan for nearby devices and watch device connections (BlueZ)
- Run a Bluetooth LE peripheral: GATT services with read, write and notify, plus an LE advertisement (BlueZ)
- Command-line interface for interactive usage

## Usage

### Basic Example

```dart
import 'package:dbus_wifi/dbus_wifi.dart';

void main() async {
  final wifi = DbusWifi();

  // Check if Wi-Fi device is available
  if (await wifi.hasWifiDevice) {
    // Search for Wi-Fi networks
    final results = await wifi.search(timeout: Duration(seconds: 7));
    print('Found ${results.length} networks');
    
    // Connect to a network
    if (results.isNotEmpty) {
      try {
        await wifi.connect(results.first, 'your_password_here');
        print('Connected to ${results.first.ssid}');
      } catch (e) {
        print('Failed to connect: $e');
      }
    }
  }

  // Always close the connection when done
  await wifi.close();
}
```

### Checking Connection Status

```dart
final status = await wifi.getConnectionStatus();
if (status['status'] == ConnectionStatus.connected) {
  final network = status['network'];
  if (network != null) {
    print('Connected to: ${network.ssid}');
    print('Signal strength: ${network.strength}%');
  }
}
```

### Disconnecting from a Network

```dart
final disconnected = await wifi.disconnect();
if (disconnected) {
  print('Successfully disconnected');
} else {
  print('Failed to disconnect');
}
```

### Viewing Saved Networks

```dart
final savedNetworks = await wifi.getSavedNetworks();
for (final network in savedNetworks) {
  print('Network: ${network['id']}, UUID: ${network['uuid']}');
}
```

### Forgetting a Network

```dart
// Forget by UUID
final forgotten = await wifi.forgetNetwork(uuid: 'network-uuid-here');

// Or forget by SSID
final forgotten = await wifi.forgetNetwork(ssid: 'network-name-here');

if (forgotten) {
  print('Network has been forgotten');
} else {
  print('Failed to forget network');
}
```

### Toggling Wi-Fi

```dart
// Check the current state
final enabled = await wifi.isWifiEnabled;
print('Wi-Fi is ${enabled ? 'enabled' : 'disabled'}');

// Turn it off (or on), returns the new state
final newState = await wifi.setWifiEnabled(!enabled);
print('Wi-Fi is now ${newState ? 'enabled' : 'disabled'}');
```

### Bluetooth LE Peripheral

Bluetooth support lives in its own entrypoint, `package:dbus_wifi/dbus_bluetooth.dart`. `BlePeripheral` exports a GATT application and an LE advertisement to BlueZ, so a phone can connect to the Linux device and exchange data.

```dart
import 'dart:typed_data';

import 'package:dbus_wifi/dbus_bluetooth.dart';

void main() async {
  final bluetooth = DbusBluetooth();
  final peripheral = BlePeripheral(bluetooth);

  late final BleGattCharacteristic echo;
  echo = BleGattCharacteristic(
    uuid: '12345678-1234-5678-1234-56789abcdef1',
    flags: {BleCharacteristicFlag.write, BleCharacteristicFlag.notify},
    onWrite: (value, request) async {
      // request carries the device, MTU and offset BlueZ passed along
      await peripheral.notify(echo, value);
    },
  );

  await peripheral.start(
    services: [
      BleGattService(uuid: '12345678-1234-5678-1234-56789abcdef0', characteristics: [echo]),
    ],
    advertisement: const BleAdvertisement(
      localName: 'my-device',
      serviceUuids: ['12345678-1234-5678-1234-56789abcdef0'],
    ),
  );

  // ...

  await peripheral.dispose();
  await bluetooth.close();
}
```

Handlers can throw a `BleGattException` (for example `BleGattError.notPermitted`) to reply with a specific error. Any other exception is sent back as `org.bluez.Error.Failed`, so a bad write never crashes the host.

### Bluetooth Adapter, Scanning and Connections

```dart
final bluetooth = DbusBluetooth();
if (await bluetooth.hasAdapter) {
  await bluetooth.setPowered(true);
  await bluetooth.setAlias('my-device');

  final devices = await bluetooth.scan(timeout: Duration(seconds: 7));
  for (final device in devices) {
    print('${device.name ?? 'Unknown'} (${device.address}) ${device.rssi} dBm');
  }

  bluetooth.connectionChanges.listen((device) {
    print('${device.address} ${device.connected ? 'connected' : 'disconnected'}');
  });
}
```

## Command-Line Interface

The package includes two CLI applications, one for Wi-Fi and one for Bluetooth. You can run them with:

```bash
dart run bin/dbus_wifi.dart
dart run bin/dbus_bluetooth.dart
```

Or install them globally:

```bash
dart pub global activate dbus_wifi
dbus-wifi
dbus-bluetooth
```

`dbus-bluetooth` shows the adapter status, toggles its power, sets its name, scans for nearby devices, lists connected devices, and runs an echo peripheral. The echo peripheral advertises as `dbus-wifi-echo` and sends every write back as a notification, so you can test the adapter with a BLE scanner app such as nRF Connect.

## API Documentation

### DbusWifi

The main class for interacting with Wi-Fi networks.

#### Methods

- `Future<bool> get hasWifiDevice` - Checks if a Wi-Fi device is available
- `Future<List<WifiNetwork>> search({Duration timeout})` - Scans for nearby Wi-Fi networks
- `Future<List<DBusValue>> connect(WifiNetwork network, String password)` - Connects to a Wi-Fi network
- `Future<bool> disconnect()` - Disconnects from the current Wi-Fi network
- `Future<Map<String, dynamic>> getConnectionStatus()` - Gets the current connection status
- `Future<List<Map<String, dynamic>>> getSavedNetworks()` - Gets a list of saved Wi-Fi networks
- `Future<bool> forgetNetwork({String? uuid, String? ssid})` - Forgets (deletes) a saved Wi-Fi network
- `Future<bool> get isWifiEnabled` - Returns whether Wi-Fi is currently enabled
- `Future<bool> setWifiEnabled(bool enabled)` - Enables or disables Wi-Fi, returning the new state
- `Future<void> close()` - Closes the D-Bus client connection

### WifiNetwork

A class representing a Wi-Fi network.

#### Properties

- `String ssid` - The network name
- `String mac` - The MAC address of the access point
- `int strength` - The signal strength (0-100)
- `DBusObjectPath path` - The D-Bus object path
- `String security` - The security type (e.g., 'wpa-psk', 'none')
- `String mode` - The network mode (e.g., 'infrastructure', 'adhoc')

### ConnectionStatus

An enum representing the connection status.

- `disconnected` - Not connected to any network
- `connected` - Connected to a network
- `connecting` - In the process of connecting
- `failed` - Connection failed

### DbusBluetooth

The class for the local Bluetooth adapter, from `package:dbus_wifi/dbus_bluetooth.dart`. Pass a `DBusClient` to use a bus other than the system bus.

#### Methods

- `Future<bool> get hasAdapter` - Checks if a Bluetooth adapter is available
- `Future<DBusObjectPath> get adapterPath` - The first adapter's path, for example `/org/bluez/hci0`
- `Future<bool> get isPowered` - Returns whether the adapter is powered on
- `Future<bool> setPowered(bool powered)` - Powers the adapter on or off, returning the new state
- `Future<String> get address` - The adapter's Bluetooth address
- `Future<String> get alias` - The adapter's friendly name
- `Future<void> setAlias(String alias)` - Sets the adapter's friendly name
- `Future<List<BleDevice>> scan({Duration timeout, BluetoothTransport transport})` - Scans for nearby devices (LE only by default) and returns them strongest signal first
- `Future<List<BleDevice>> get connectedDevices` - Devices currently connected to the adapter
- `Stream<BleDevice> get connectionChanges` - Emits each time a device connects or disconnects
- `Future<void> disconnect(DBusObjectPath device)` - Disconnects a remote device
- `Future<void> close()` - Closes the D-Bus client connection if this instance created it

### BlePeripheral

Runs a GATT server and LE advertisement on the adapter of a `DbusBluetooth`.

#### Methods

- `Future<void> start({required List<BleGattService> services, required BleAdvertisement advertisement})` - Exports the services, registers them with BlueZ and starts advertising
- `Future<void> stop()` - Stops advertising, unregisters the application and removes the exported objects
- `Future<bool> notify(BleGattCharacteristic characteristic, Uint8List value)` - Sends a notification, returning false when no device is subscribed
- `bool isNotifying(BleGattCharacteristic characteristic)` - Whether a device is subscribed
- `Stream<BleSubscription> get subscriptions` - Emits when a device starts or stops notifications
- `Stream<void> get released` - Emits when BlueZ drops the advertisement
- `Future<void> dispose()` - Stops the peripheral and closes its streams

### BleGattService, BleGattCharacteristic and BleAdvertisement

- `BleGattService` - `uuid`, `characteristics` and `primary` (default true)
- `BleGattCharacteristic` - `uuid`, `flags` (a set of `BleCharacteristicFlag`), optional `onRead`, `onWrite` and `initialValue`. Without `onRead`, reads return the last written or notified value.
- `BleAdvertisement` - `localName`, `serviceUuids`, `manufacturerData`, `serviceData`, `includeTxPower` and `discoverable`
- `BleRequest` - The `device`, `mtu`, `offset`, `link` and `writeType` of a read or write
- `BleDevice` - A remote device's `path`, `address`, `name`, `connected` state and `rssi` (only known while it is being discovered)

## More Examples

For more detailed examples, see the [examples directory](https://github.com/akshaybabloo/dbus_wifi/tree/main/example).

## Requirements

- Linux operating system
- NetworkManager, for Wi-Fi
- BlueZ 5.56 or newer, for Bluetooth. The user needs D-Bus access to `org.bluez`.
- D-Bus

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
