# Examples

## Basic Usage

```dart
void main() async {
  final wifi = DbusWifi();

  // Check if Wi-Fi device is available
  if (await wifi.hasWifiDevice) {
    // Search for Wi-Fi networks
    final results = await wifi.search(timeout: Duration(seconds: 7));
    print('Found ${results.length} networks');
    
    // Connect to a network (e.g., the first one in the list)
    if (results.isNotEmpty) {
      try {
        await wifi.connect(results.first, 'your_password_here');
        print('Connected to ${results.first.ssid}');
      } catch (e) {
        print('Failed to connect: $e');
      }
    }
    
    // Check connection status
    final status = await wifi.getConnectionStatus();
    if (status['status'] == ConnectionStatus.connected) {
      final network = status['network'];
      if (network != null) {
        print('Connected to: ${network.ssid}');
      }
    }
    
    // Disconnect from network
    final disconnected = await wifi.disconnect();
    print('Disconnected: $disconnected');
  }

  // Always close the connection when done
  await wifi.close();
}
```

## Interactive CLI Example

The package includes a full-featured CLI application that demonstrates all the functionality. You can run it with:

```bash
dart run bin/dbus_wifi.dart
```

Or install it globally:

```bash
dart pub global activate dbus_wifi
dbus-wifi
```

The CLI application provides a menu-driven interface to:
- Scan for networks
- Connect to a selected network
- Check connection status
- Disconnect from the current network

See the [bin/dbus_wifi.dart](https://github.com/akshaybabloo/dbus_wifi/blob/main/bin/dbus_wifi.dart) file for the complete implementation.
