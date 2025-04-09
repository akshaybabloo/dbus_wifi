import 'package:dbus/dbus.dart';

/// Represents a Wi-Fi network
class WifiNetwork {
  final String ssid;
  final String mac;
  final int strength;
  final DBusObjectPath path;
  final String security;
  final String mode;

  WifiNetwork({
    required this.ssid,
    required this.mac,
    required this.strength,
    required this.path,
    required this.security,
    required this.mode,
  });

  @override
  String toString() => 'SSID: $ssid, MAC: $mac, Strength: $strength, Path: $path, Security: $security, Mode: $mode';
}
