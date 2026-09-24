import 'package:dbus_wifi/models/ble_gatt_characteristic.dart';

/// A GATT service to expose from a [BlePeripheral]
class BleGattService {
  final String uuid;
  final bool primary;
  final List<BleGattCharacteristic> characteristics;

  const BleGattService({required this.uuid, required this.characteristics, this.primary = true});

  @override
  String toString() => 'UUID: $uuid, Primary: $primary, Characteristics: ${characteristics.length}';
}
