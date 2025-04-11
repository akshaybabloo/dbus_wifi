# DBus Wi-Fi

A native implementation for setting up Wi-Fi using DBus.

## Usage

A complete example can be found in [dbus_wifi.dart](https://github.com/akshaybabloo/dbus_wifi/blob/main/bin/dbus_wifi.dart)

```dart
void main() async {
  final wifi = DbusWifi();

  // Search for Wi-Fi devices
  final results = await wifi.search(timeout: Duration(seconds: 7));
  
  // Choose a Wi-Fi from above result, for example, let's take the first one
  await wifi.connect(results.first, password!);

  // Close the connection
  await wifi.close();
}
```
