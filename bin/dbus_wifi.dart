import 'package:dbus_wifi/dbus_wifi.dart';

void main() async {
  final wifi = DbusWifi();

  if (await wifi.hasWifiDevice) {
    print('Wi-Fi device found. Scanning for networks...');
    final results = await wifi.search(timeout: Duration(seconds: 7));
    print('Found ${results.length} networks:\n');
    for (final ap in results) {
      print(ap);
    }
  } else {
    print('No Wi-Fi device found.');
  }

  await wifi.close();
}
