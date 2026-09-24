import 'package:dbus/dbus.dart';

/// Details BlueZ passes along with a GATT read or write from a remote device
class BleRequest {
  /// The remote device making the request
  final DBusObjectPath? device;

  /// The negotiated ATT MTU for the link, when BlueZ reports it
  final int? mtu;

  /// Byte offset for long reads and writes
  final int offset;

  /// The transport of the link, for example 'LE' or 'BR/EDR'
  final String? link;

  /// The write type for writes: 'command', 'request' or 'reliable'
  final String? writeType;

  const BleRequest({this.device, this.mtu, this.offset = 0, this.link, this.writeType});

  /// Parses the `a{sv}` options dictionary of `ReadValue` and `WriteValue`
  factory BleRequest.fromOptions(Map<String, DBusValue> options) {
    final device = options['device'];
    final mtu = options['mtu'];
    final offset = options['offset'];
    final link = options['link'];
    final type = options['type'];
    return BleRequest(
      device: device is DBusObjectPath ? device : null,
      mtu: mtu is DBusUint16 ? mtu.value : null,
      offset: offset is DBusUint16 ? offset.value : 0,
      link: link is DBusString ? link.value : null,
      writeType: type is DBusString ? type.value : null,
    );
  }

  /// The largest payload that fits in a single notification on this link, if the MTU is known
  int? get maxNotifyLength => mtu == null ? null : mtu! - 3;

  @override
  String toString() => 'Device: $device, MTU: $mtu, Offset: $offset, Link: $link, Type: $writeType';
}
