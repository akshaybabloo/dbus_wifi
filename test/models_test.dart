import 'package:dbus/dbus.dart';
import 'package:dbus_wifi/dbus_bluetooth.dart';
import 'package:test/test.dart';

void main() {
  group('BleCharacteristicFlag', () {
    test('maps to BlueZ flag strings', () {
      expect(BleCharacteristicFlag.writeWithoutResponse.value, 'write-without-response');
      expect(BleCharacteristicFlag.encryptAuthenticatedRead.value, 'encrypt-authenticated-read');
      expect(BleCharacteristicFlag.notify.value, 'notify');
    });

    test('classifies read, write and notify flags', () {
      expect(BleCharacteristicFlag.secureRead.allowsRead, isTrue);
      expect(BleCharacteristicFlag.secureRead.allowsWrite, isFalse);
      expect(BleCharacteristicFlag.encryptWrite.allowsWrite, isTrue);
      expect(BleCharacteristicFlag.authenticatedSignedWrites.allowsWrite, isTrue);
      expect(BleCharacteristicFlag.indicate.allowsNotify, isTrue);
      expect(BleCharacteristicFlag.broadcast.allowsRead, isFalse);
    });
  });

  group('BleGattCharacteristic', () {
    test('derives capabilities from its flags', () {
      const characteristic = BleGattCharacteristic(
        uuid: '1234',
        flags: {BleCharacteristicFlag.encryptWrite, BleCharacteristicFlag.notify},
      );
      expect(characteristic.canRead, isFalse);
      expect(characteristic.canWrite, isTrue);
      expect(characteristic.canNotify, isTrue);
    });
  });

  group('BleRequest', () {
    test('parses BlueZ options', () {
      final request = BleRequest.fromOptions({
        'device': DBusObjectPath('/org/bluez/hci0/dev_AA_BB_CC_DD_EE_FF'),
        'mtu': DBusUint16(247),
        'offset': DBusUint16(22),
        'link': DBusString('LE'),
        'type': DBusString('request'),
      });
      expect(request.device, DBusObjectPath('/org/bluez/hci0/dev_AA_BB_CC_DD_EE_FF'));
      expect(request.mtu, 247);
      expect(request.offset, 22);
      expect(request.link, 'LE');
      expect(request.writeType, 'request');
      expect(request.maxNotifyLength, 244);
    });

    test('defaults missing options', () {
      final request = BleRequest.fromOptions({});
      expect(request.device, isNull);
      expect(request.mtu, isNull);
      expect(request.offset, 0);
      expect(request.maxNotifyLength, isNull);
    });
  });

  group('BleDevice', () {
    test('recovers the address from a device path', () {
      expect(BleDevice.addressFromPath(DBusObjectPath('/org/bluez/hci0/dev_AA_BB_CC_DD_EE_FF')), 'AA:BB:CC:DD:EE:FF');
    });
  });
}
