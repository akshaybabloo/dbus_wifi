/// Which kinds of devices a Bluetooth scan looks for
enum BluetoothTransport {
  /// Both Bluetooth LE and classic devices
  auto('auto'),

  /// Bluetooth LE devices only
  le('le'),

  /// Classic (BR/EDR) devices only
  bredr('bredr');

  /// The value BlueZ expects for the `Transport` discovery filter
  final String value;

  const BluetoothTransport(this.value);
}
