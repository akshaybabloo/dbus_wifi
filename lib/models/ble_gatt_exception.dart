/// Errors a GATT handler can return to the remote device
enum BleGattError {
  failed('org.bluez.Error.Failed'),
  inProgress('org.bluez.Error.InProgress'),
  notPermitted('org.bluez.Error.NotPermitted'),
  invalidValueLength('org.bluez.Error.InvalidValueLength'),
  invalidOffset('org.bluez.Error.InvalidOffset'),
  notAuthorized('org.bluez.Error.NotAuthorized'),
  notSupported('org.bluez.Error.NotSupported');

  /// The D-Bus error name BlueZ maps to an ATT error code
  final String errorName;

  const BleGattError(this.errorName);
}

/// Throw from a read or write handler to reply with a specific BlueZ error
class BleGattException implements Exception {
  final BleGattError error;
  final String? message;

  const BleGattException(this.error, [this.message]);

  @override
  String toString() => 'BleGattException: ${error.errorName}${message == null ? '' : ' ($message)'}';
}
