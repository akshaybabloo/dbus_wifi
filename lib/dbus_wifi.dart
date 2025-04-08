import 'dart:async';
import 'package:dbus/dbus.dart';
import 'package:dbus_wifi/interfaces/wifi_remote_object.dart';
import 'package:dbus_wifi/models/wifi_network.dart';

class DbusWifi {
  final DBusClient _client;
  DBusRemoteObject? _wifiDevice;

  DbusWifi() : _client = DBusClient.system();

  /// Checks if a Wi-Fi device is available
  Future<bool> get hasWifiDevice async {
    final nm = OrgFreedesktopNetworkManager(_client, 'org.freedesktop.NetworkManager');
    final devices = await nm.callGetAllDevices();

    for (final devicePath in devices) {
      final dev = OrgFreedesktopNetworkManager(_client, 'org.freedesktop.NetworkManager', path: devicePath);
      final type = await dev.getDeviceType();
      if (type == 2) {
        _wifiDevice = DBusRemoteObject(_client, name: 'org.freedesktop.NetworkManager', path: devicePath);
        return true;
      }
    }
    return false;
  }

  /// Scans for nearby Wi-Fi networks
  Future<List<WifiNetwork>> search({Duration timeout = const Duration(seconds: 5)}) async {
    if (!await hasWifiDevice) {
      throw Exception('No Wi-Fi device found.');
    }

    final dev = OrgFreedesktopNetworkManager(_client, 'org.freedesktop.NetworkManager', path: _wifiDevice!.path);

    await dev.callRequestScan({});
    await Future.delayed(timeout);

    final accessPoints = await dev.callGetAllAccessPoints();
    final List<WifiNetwork> results = [];

    for (final apPath in accessPoints) {
      final ap = OrgFreedesktopNetworkManager(_client, 'org.freedesktop.NetworkManager', path: apPath);

      try {
        final ssidBytes = await ap.getSsid();
        final ssid = String.fromCharCodes(ssidBytes);
        final mac = await ap.getHwAddress();
        final strength = await ap.getStrength();
        results.add(WifiNetwork(ssid: ssid, mac: mac, strength: strength, path: apPath));
      } catch (e) {
        // Silently skip APs that can't be read
      }
    }

    return results;
  }

  Future<void> close() async {
    await _client.close();
  }
}
