/// An LE advertisement to register with BlueZ
class BleAdvertisement {
  /// The name shown to scanning devices
  final String? localName;

  /// Service UUIDs to advertise, so scanners can filter on them
  final List<String> serviceUuids;

  /// Manufacturer specific data keyed by company identifier
  final Map<int, List<int>> manufacturerData;

  /// Service data keyed by service UUID
  final Map<String, List<int>> serviceData;

  /// Adds the TX power level to the advertisement
  final bool includeTxPower;

  /// Sets the LE discoverable flag. Null leaves it to BlueZ.
  final bool? discoverable;

  const BleAdvertisement({
    this.localName,
    this.serviceUuids = const [],
    this.manufacturerData = const {},
    this.serviceData = const {},
    this.includeTxPower = false,
    this.discoverable,
  });

  @override
  String toString() => 'Name: $localName, Services: $serviceUuids, Discoverable: $discoverable';
}
