# DBus Wi-Fi

A native implementation for managing Wi-Fi networks using D-Bus on Linux. This library provides a simple interface to scan for networks, connect to them, check connection status, and disconnect.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  dbus_wifi: ^0.0.3
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

## Command-Line Interface

The package includes a CLI application that can be used to manage Wi-Fi networks. You can run it with:

```bash
dart run bin/dbus_wifi.dart
```

Or install it globally:

```bash
dart pub global activate dbus_wifi
dbus-wifi
```

## API Documentation

### DbusWifi

The main class for interacting with Wi-Fi networks.

#### Methods

- `Future<bool> get hasWifiDevice` - Checks if a Wi-Fi device is available
- `Future<List<WifiNetwork>> search({Duration timeout})` - Scans for nearby Wi-Fi networks
- `Future<List<DBusValue>> connect(WifiNetwork network, String password)` - Connects to a Wi-Fi network
- `Future<bool> disconnect()` - Disconnects from the current Wi-Fi network
- `Future<Map<String, dynamic>> getConnectionStatus()` - Gets the current connection status
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

## More Examples

For more detailed examples, see the [examples directory](https://github.com/akshaybabloo/dbus_wifi/tree/main/example).

## Requirements

- Linux operating system
- NetworkManager
- D-Bus

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
