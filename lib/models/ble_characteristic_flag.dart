/// GATT characteristic flags understood by BlueZ
enum BleCharacteristicFlag {
  broadcast('broadcast'),
  read('read'),
  writeWithoutResponse('write-without-response'),
  write('write'),
  notify('notify'),
  indicate('indicate'),
  authenticatedSignedWrites('authenticated-signed-writes'),
  reliableWrite('reliable-write'),
  writableAuxiliaries('writable-auxiliaries'),
  encryptRead('encrypt-read'),
  encryptWrite('encrypt-write'),
  encryptAuthenticatedRead('encrypt-authenticated-read'),
  encryptAuthenticatedWrite('encrypt-authenticated-write'),
  secureRead('secure-read'),
  secureWrite('secure-write');

  /// The flag string BlueZ expects in `GattCharacteristic1.Flags`
  final String value;

  const BleCharacteristicFlag(this.value);

  bool get allowsRead => this == read || name.endsWith('Read');

  bool get allowsWrite =>
      this == write ||
      this == writeWithoutResponse ||
      this == authenticatedSignedWrites ||
      this == reliableWrite ||
      name.endsWith('Write');

  bool get allowsNotify => this == notify || this == indicate;
}
