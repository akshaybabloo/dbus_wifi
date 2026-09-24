import 'package:dbus/dbus.dart';

/// A remote Bluetooth device known to BlueZ
class BleDevice {
  final DBusObjectPath path;
  final String address;
  final String? name;
  final bool connected;

  /// Signal strength in dBm, only known while the device is being discovered
  final int? rssi;

  const BleDevice({required this.path, required this.address, this.name, required this.connected, this.rssi});

  /// Recovers the address from a BlueZ device path such as `/org/bluez/hci0/dev_AA_BB_CC_DD_EE_FF`
  static String addressFromPath(DBusObjectPath path) {
    final last = path.value.split('/').last;
    return last.startsWith('dev_') ? last.substring(4).replaceAll('_', ':') : last;
  }

  @override
  String toString() => 'Address: $address, Name: $name, Connected: $connected, RSSI: $rssi, Path: $path';
}
