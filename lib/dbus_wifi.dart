import 'dart:async';
import 'dart:convert';
import 'package:dbus/dbus.dart';
import 'package:dbus_wifi/interfaces/nm_settings_remote_object.dart';
import 'package:dbus_wifi/interfaces/wifi_remote_object.dart';
import 'package:dbus_wifi/models/wifi_network.dart';

/// Connection status for a Wi-Fi network
enum ConnectionStatus {
  /// Not connected to any network
  disconnected,

  /// Connected to a network
  connected,

  /// In the process of connecting
  connecting,

  /// Connection failed
  failed
}

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
  ///
  /// Returns a list of DBusValues containing the connection path and active connection path.
  /// Throws an exception if:
  /// - No Wi-Fi device is found
  /// - The connection fails (authentication error, network unavailable, etc.)
  /// - There's an issue with the D-Bus communication
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

    try {
      return await manager.callAddAndActivateConnection(connection, _wifiDevice!.path, DBusObjectPath('/'));
    } catch (e) {
      if (e.toString().contains('Auth')) {
        throw Exception('Authentication failed. Check your password and try again.');
      } else if (e.toString().contains('No network')) {
        throw Exception('Network unavailable. The selected network may be out of range.');
      } else {
        throw Exception('Failed to connect to network: $e');
      }
    }
  }

  /// Disconnects from the current Wi-Fi network
  ///
  /// Returns true if successfully disconnected, false otherwise.
  /// Throws an exception if no Wi-Fi device is found.
  Future<bool> disconnect() async {
    if (!await hasWifiDevice) {
      throw Exception('No Wi-Fi device found.');
    }

    try {
      // Set wireless to disabled and then enabled again to disconnect
      final nm = OrgFreedesktopNetworkManager(_client, 'org.freedesktop.NetworkManager');

      // Disable wireless
      await nm.setWirelessEnabled(false);
      await Future.delayed(Duration(seconds: 1));

      // Enable wireless again
      await nm.setWirelessEnabled(true);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gets a list of saved Wi-Fi networks
  ///
  /// Returns a list of maps containing the network details.
  /// Each map contains the following keys:
  /// - id: The connection ID (usually the SSID)
  /// - uuid: The connection UUID
  /// - path: The D-Bus object path
  /// - type: The connection type (usually '802-11-wireless')
  Future<List<Map<String, dynamic>>> getSavedNetworks() async {
    final settings = OrgFreedesktopNetworkManagerSettings(_client, 'org.freedesktop.NetworkManager');
    final connections = await settings.callListConnections();

    final List<Map<String, dynamic>> savedNetworks = [];

    for (final connectionPath in connections) {
      final connection =
          OrgFreedesktopNetworkManagerSettings(_client, 'org.freedesktop.NetworkManager', path: connectionPath);

      try {
        final settings = await connection.callGetSettings();

        // Check if this is a Wi-Fi connection
        if (settings.containsKey('802-11-wireless')) {
          final connectionSettings = settings['connection']!;
          final id = connectionSettings['id']?.asString() ?? 'Unknown';
          final uuid = connectionSettings['uuid']?.asString() ?? '';
          final type = connectionSettings['type']?.asString() ?? '';

          savedNetworks.add({
            'id': id,
            'uuid': uuid,
            'path': connectionPath,
            'type': type,
          });
        }
      } catch (e) {
        // Skip connections that can't be read
        continue;
      }
    }

    return savedNetworks;
  }

  /// Forgets (deletes) a saved Wi-Fi network
  ///
  /// Takes either a connection UUID or a network SSID.
  /// If both are provided, UUID takes precedence.
  /// Returns true if the network was successfully forgotten, false otherwise.
  Future<bool> forgetNetwork({String? uuid, String? ssid}) async {
    if (uuid == null && ssid == null) {
      throw Exception('Either uuid or ssid must be provided.');
    }

    final settings = OrgFreedesktopNetworkManagerSettings(_client, 'org.freedesktop.NetworkManager');

    try {
      if (uuid != null) {
        // Get connection by UUID
        final connectionPath = await settings.callGetConnectionByUuid(uuid);
        final connection =
            OrgFreedesktopNetworkManagerSettings(_client, 'org.freedesktop.NetworkManager', path: connectionPath);
        await connection.callDelete();
        return true;
      } else {
        // Find connection by SSID
        final connections = await settings.callListConnections();

        for (final connectionPath in connections) {
          final connection =
              OrgFreedesktopNetworkManagerSettings(_client, 'org.freedesktop.NetworkManager', path: connectionPath);

          try {
            final settings = await connection.callGetSettings();

            // Check if this is a Wi-Fi connection with the matching SSID
            if (settings.containsKey('802-11-wireless')) {
              final connectionSettings = settings['connection']!;
              final id = connectionSettings['id']?.asString() ?? '';

              if (id == ssid) {
                await connection.callDelete();
                return true;
              }
            }
          } catch (e) {
            // Skip connections that can't be read
            continue;
          }
        }

        return false; // No matching connection found
      }
    } catch (e) {
      return false;
    }
  }

  /// Gets the current connection status
  ///
  /// Returns a [ConnectionStatus] enum value indicating the current status.
  /// Also returns the currently connected network if connected.
  /// Throws an exception if no Wi-Fi device is found.
  Future<Map<String, dynamic>> getConnectionStatus() async {
    if (!await hasWifiDevice) {
      throw Exception('No Wi-Fi device found.');
    }

    try {
      final dev = OrgFreedesktopNetworkManager(_client, 'org.freedesktop.NetworkManager', path: _wifiDevice!.path);

      // Get the active access point
      final activeAccessPoint = await dev.getActiveAccessPoint();

      // If there's no active access point or it's the root path, we're disconnected
      if (activeAccessPoint.value == '/') {
        return {
          'status': ConnectionStatus.disconnected,
          'network': null,
        };
      }

      // Get the access point details
      final ap = OrgFreedesktopNetworkManager(_client, 'org.freedesktop.NetworkManager', path: activeAccessPoint);

      try {
        final ssidBytes = await ap.getSsid();
        final ssid = String.fromCharCodes(ssidBytes);
        final mac = await ap.getHwAddress();
        final strength = await ap.getStrength();
        final security = await _determineSecurityType(ap);
        final mode = await _determineWifiMode(dev);

        final network = WifiNetwork(
          ssid: ssid,
          mac: mac,
          strength: strength,
          path: activeAccessPoint,
          security: security,
          mode: mode,
        );

        return {
          'status': ConnectionStatus.connected,
          'network': network,
        };
      } catch (e) {
        return {
          'status': ConnectionStatus.connected,
          'network': null,
          'error': 'Failed to read access point details: $e',
        };
      }
    } catch (e) {
      return {
        'status': ConnectionStatus.failed,
        'network': null,
        'error': 'Failed to get connection status: $e',
      };
    }
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
