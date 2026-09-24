import 'dart:async';
import 'dart:typed_data';

import 'package:dbus_wifi/models/ble_characteristic_flag.dart';
import 'package:dbus_wifi/models/ble_request.dart';

/// Returns the full value of a characteristic; offsets for long reads are applied by the peripheral
typedef BleReadHandler = FutureOr<Uint8List> Function(BleRequest request);

/// Receives a value written by a remote device
typedef BleWriteHandler = FutureOr<void> Function(Uint8List value, BleRequest request);

/// A GATT characteristic to expose from a [BlePeripheral]
///
/// Without [onRead], reads return the last written or notified value, starting with [initialValue].
/// Handlers can throw a [BleGattException] to reply with a specific error.
class BleGattCharacteristic {
  final String uuid;
  final Set<BleCharacteristicFlag> flags;
  final BleReadHandler? onRead;
  final BleWriteHandler? onWrite;
  final Uint8List? initialValue;

  const BleGattCharacteristic({
    required this.uuid,
    required this.flags,
    this.onRead,
    this.onWrite,
    this.initialValue,
  });

  bool get canRead => flags.any((flag) => flag.allowsRead);

  bool get canWrite => flags.any((flag) => flag.allowsWrite);

  bool get canNotify => flags.any((flag) => flag.allowsNotify);

  @override
  String toString() => 'UUID: $uuid, Flags: ${flags.map((flag) => flag.value).join(',')}';
}
