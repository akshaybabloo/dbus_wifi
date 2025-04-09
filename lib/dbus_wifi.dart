import 'dart:async';
import 'dart:convert';
import 'package:dbus/dbus.dart';
import 'package:dbus_wifi/interfaces/wifi_remote_object.dart';
import 'package:dbus_wifi/models/wifi_network.dart';

/// A class to interact with Wi-Fi networks using D-Bus
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
  ///
  /// Returns a list of [WifiNetwork] objects representing the found networks.
  /// If no Wi-Fi device is found, an exception is thrown.
  /// If unable to read an access point, an exception is thrown.
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
        final security = await _determineSecurityType(ap);
        final mode = await _determineWifiMode(dev);

        results
            .add(WifiNetwork(ssid: ssid, mac: mac, strength: strength, path: apPath, security: security, mode: mode));
      } catch (e) {
        throw Exception('Failed to read access point: $e');
      }
    }

    return results;
  }

  /// Connects to a Wi-Fi network
  Future<List<DBusValue>> connect(WifiNetwork network, String password) async {
    if (!await hasWifiDevice) {
      throw Exception('No Wi-Fi device found.');
    }

    final manager = OrgFreedesktopNetworkManager(_client, 'org.freedesktop.NetworkManager');

    final connection = {
      'connection': {
        'id': DBusString(network.ssid),
        'type': DBusString('802-11-wireless'),
      },
      '802-11-wireless': {
        'mode': DBusString('infrastructure'),
        'ssid': DBusArray.byte(utf8.encode(network.ssid)),
        'security': DBusString('802-11-wireless-security'),
      },
      '802-11-wireless-security': {
        'key-mgmt': DBusString(network.security),
        'psk': DBusString(password),
      },
      'ipv4': {
        'method': DBusString('auto'),
      },
      'ipv6': {
        'method': DBusString('ignore'),
      },
    };

    return await manager.callAddAndActivateConnection(connection, _wifiDevice!.path, DBusObjectPath('/'));
  }

  /// Closes the D-Bus client connection
  Future<void> close() async {
    await _client.close();
  }

  /// Returns the security type of the Wi-Fi network
  ///
  /// This method checks the RSN and WPA flags to determine the security type.
  /// Exception is thrown if no security type is found.
  Future<String> _determineSecurityType(OrgFreedesktopNetworkManager ap) async {
    if (!await hasWifiDevice) {
      throw Exception('No Wi-Fi device found.');
    }

    final rsn = await ap.getRsnFlags();
    final wpa = await ap.getWpaFlags();

    var security = 'none';
    if ((rsn & 0x00002000) != 0) {
      security = 'wpa-eap-suite-b-192';
    } else if ((rsn & 0x00000200) != 0) {
      security = 'wpa-eap';
    } else if ((rsn & 0x00000800) != 0 || (wpa & 0x00000800) != 0) {
      security = 'owe';
    } else if ((rsn & 0x00000400) != 0) {
      security = 'sae';
    } else if ((rsn & 0x00000100) != 0 || (wpa & 0x00000100) != 0) {
      security = 'wpa-psk';
    } else if ((wpa & 0x00000001) != 0 || (wpa & 0x00000002) != 0) {
      security = 'none';
    }

    return security;
  }

  /// Returns the mode of the Wi-Fi network
  Future<String> _determineWifiMode(OrgFreedesktopNetworkManager ap) async {
    if (!await hasWifiDevice) {
      throw Exception('No Wi-Fi device found.');
    }

    final mode = await ap.getMode();
    switch (mode) {
      case 0:
        return "unknown";
      case 1:
        return "adhoc";
      case 2:
        return "infrastructure";
      case 3:
        return "ap";
      case 4:
        return "mesh";
      default:
        throw Exception('Unknown mode: $mode');
    }
  }
}
