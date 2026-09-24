import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dbus/dbus.dart';
import 'package:dbus_wifi/dbus_bluetooth.dart';
import 'package:test/test.dart';

import 'support/fake_bluez.dart';

const _serviceUuid = '12345678-1234-5678-1234-56789abcdef0';
const _rxUuid = '12345678-1234-5678-1234-56789abcdef1';
const _txUuid = '12345678-1234-5678-1234-56789abcdef2';

void main() {
  late DBusServer server;
  late DBusClient bluezClient;
  late DBusClient appClient;
  late FakeBluez bluez;
  late DbusBluetooth bluetooth;

  setUp(() async {
    server = DBusServer();
    final address = await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    bluezClient = DBusClient(address);
    appClient = DBusClient(address);
    bluez = FakeBluez(bluezClient);
    await bluez.start();
    bluetooth = DbusBluetooth(client: appClient);
  });

  tearDown(() async {
    await bluetooth.close();
    await appClient.close();
    await bluezClient.close();
    await server.close();
  });

  group('DbusBluetooth', () {
    test('finds the adapter', () async {
      expect(await bluetooth.hasAdapter, isTrue);
      expect(await bluetooth.adapterPath, DBusObjectPath(adapterPath));
      expect(await bluetooth.address, '00:11:22:33:44:55');
    });

    test('toggles power and sets the alias', () async {
      expect(await bluetooth.isPowered, isTrue);
      expect(await bluetooth.setPowered(false), isFalse);
      expect(bluez.adapter.powered, isFalse);

      await bluetooth.setAlias('Frame-1234');
      expect(await bluetooth.alias, 'Frame-1234');
    });

    test('scans for nearby devices, strongest first', () async {
      await bluez.addDevice('AA:BB:CC:DD:EE:10');
      bluez.adapter.nearby.addAll([
        FakeDevice('AA:BB:CC:DD:EE:11', rssi: -80),
        FakeDevice('AA:BB:CC:DD:EE:12', rssi: -40),
      ]);

      final devices = await bluetooth.scan(timeout: const Duration(milliseconds: 50));

      expect(devices.map((device) => (device.address, device.rssi)), [
        ('AA:BB:CC:DD:EE:12', -40),
        ('AA:BB:CC:DD:EE:11', -80),
      ]);
      expect(bluez.adapter.discovering, isFalse);
      expect(bluez.adapter.discoveryFilters, [
        {'Transport': DBusString('le')},
        <String, DBusValue>{},
      ]);
    });

    test('refuses to scan while powered off', () async {
      await bluetooth.setPowered(false);
      await expectLater(bluetooth.scan(timeout: Duration.zero), throwsException);
      expect(bluez.adapter.discovering, isFalse);
    });

    test('lists connected devices', () async {
      await bluez.addDevice('AA:BB:CC:DD:EE:01', connected: true);
      await bluez.addDevice('AA:BB:CC:DD:EE:02');

      final devices = await bluetooth.connectedDevices;
      expect(devices.map((device) => device.address), ['AA:BB:CC:DD:EE:01']);
      expect(devices.single.name, 'Phone AA:BB:CC:DD:EE:01');
    });

    test('reports connection changes', () async {
      final device = await bluez.addDevice('AA:BB:CC:DD:EE:03');
      final changes = <BleDevice>[];
      final subscription = bluetooth.connectionChanges.listen(changes.add);
      await _settle();

      await device.setConnected(true);
      await _settle();
      await bluetooth.disconnect(device.path);
      await _settle();
      await subscription.cancel();

      expect(changes.map((change) => (change.address, change.connected)), [
        ('AA:BB:CC:DD:EE:03', true),
        ('AA:BB:CC:DD:EE:03', false),
      ]);
    });

    test('reports a connected device disappearing as a disconnect', () async {
      final changes = <BleDevice>[];
      final subscription = bluetooth.connectionChanges.listen(changes.add);
      await _settle();

      final device = await bluez.addDevice('AA:BB:CC:DD:EE:04', connected: true);
      await _settle();
      await bluez.removeDevice(device);
      await _settle();
      await subscription.cancel();

      expect(changes.map((change) => change.connected), [true, false]);
    });
  });

  group('BlePeripheral', () {
    late BlePeripheral peripheral;
    late List<(Uint8List, BleRequest)> writes;
    late BleGattCharacteristic rx;
    late BleGattCharacteristic tx;
    late BleGattCharacteristic info;

    final rxPath = DBusObjectPath('/dbus_wifi/ble/app/service0/char0');
    final txPath = DBusObjectPath('/dbus_wifi/ble/app/service0/char1');
    final infoPath = DBusObjectPath('/dbus_wifi/ble/app/service0/char2');

    setUp(() async {
      writes = [];
      rx = BleGattCharacteristic(
        uuid: _rxUuid,
        flags: {BleCharacteristicFlag.write},
        onWrite: (value, request) {
          if (value.isEmpty) {
            throw const BleGattException(BleGattError.invalidValueLength, 'empty');
          }
          if (value.first == 0xff) {
            throw StateError('boom');
          }
          writes.add((value, request));
        },
      );
      tx = const BleGattCharacteristic(uuid: _txUuid, flags: {BleCharacteristicFlag.notify});
      info = BleGattCharacteristic(
        uuid: '2a29',
        flags: {BleCharacteristicFlag.read},
        onRead: (request) => Uint8List.fromList('Frame Labs'.codeUnits),
      );
      peripheral = BlePeripheral(bluetooth);
      await peripheral.start(
        services: [
          BleGattService(uuid: _serviceUuid, characteristics: [rx, tx, info]),
        ],
        advertisement: const BleAdvertisement(
          localName: 'Frame-1234',
          serviceUuids: [_serviceUuid],
          manufacturerData: {
            0xffff: [1, 2]
          },
          includeTxPower: true,
        ),
      );
    });

    tearDown(() async {
      if (peripheral.isRunning) {
        await peripheral.stop();
      }
    });

    test('registers the GATT tree with BlueZ', () {
      final objects = bluez.adapter.applicationObjects!;
      expect(bluez.adapter.application, DBusObjectPath('/dbus_wifi/ble/app'));

      final service = objects[DBusObjectPath('/dbus_wifi/ble/app/service0')]!['org.bluez.GattService1']!;
      expect(service['UUID'], DBusString(_serviceUuid));
      expect(service['Primary'], DBusBoolean(true));

      final rxProperties = objects[rxPath]!['org.bluez.GattCharacteristic1']!;
      expect(rxProperties['UUID'], DBusString(_rxUuid));
      expect(rxProperties['Service'], DBusObjectPath('/dbus_wifi/ble/app/service0'));
      expect(rxProperties['Flags'], DBusArray.string(['write']));
      expect(objects.containsKey(txPath), isTrue);
      expect(objects.containsKey(DBusObjectPath('/dbus_wifi/ble/advertisement')), isFalse);
    });

    test('registers the advertisement', () {
      final properties = bluez.adapter.advertisementProperties!;
      expect(peripheral.isAdvertising, isTrue);
      expect(properties['Type'], DBusString('peripheral'));
      expect(properties['LocalName'], DBusString('Frame-1234'));
      expect(properties['ServiceUUIDs'], DBusArray.string([_serviceUuid]));
      expect(properties['Includes'], DBusArray.string(['tx-power']));
      expect(properties['ManufacturerData']!.asDict().keys.single, DBusUint16(0xffff));
      expect(properties.containsKey('Discoverable'), isFalse);
    });

    test('passes writes and their options to the handler', () async {
      await bluez.adapter.applicationObject(rxPath).callMethod(
          'org.bluez.GattCharacteristic1',
          'WriteValue',
          [
            DBusArray.byte([1, 2, 3]),
            DBusDict.stringVariant({'mtu': DBusUint16(185), 'device': DBusObjectPath('$adapterPath/dev_AA')}),
          ],
          replySignature: DBusSignature(''));

      expect(writes.single.$1, [1, 2, 3]);
      expect(writes.single.$2.mtu, 185);
      expect(writes.single.$2.device, DBusObjectPath('$adapterPath/dev_AA'));
    });

    test('maps handler errors to BlueZ errors', () async {
      final object = bluez.adapter.applicationObject(rxPath);
      Future<void> write(List<int> value) => object.callMethod(
          'org.bluez.GattCharacteristic1',
          'WriteValue',
          [
            DBusArray.byte(value),
            DBusDict.stringVariant({}),
          ],
          replySignature: DBusSignature(''));

      await expectLater(
        write([]),
        throwsA(isA<DBusMethodResponseException>()
            .having((e) => e.errorName, 'errorName', 'org.bluez.Error.InvalidValueLength')),
      );
      await expectLater(
        write([0xff]),
        throwsA(isA<DBusMethodResponseException>().having((e) => e.errorName, 'errorName', 'org.bluez.Error.Failed')),
      );
    });

    test('rejects reads on a write-only characteristic', () async {
      await expectLater(
        bluez.adapter.applicationObject(rxPath).callMethod('org.bluez.GattCharacteristic1', 'ReadValue', [
          DBusDict.stringVariant({}),
        ]),
        throwsA(
            isA<DBusMethodResponseException>().having((e) => e.errorName, 'errorName', 'org.bluez.Error.NotPermitted')),
      );
    });

    test('applies the read offset', () async {
      final response = await bluez.adapter.applicationObject(infoPath).callMethod(
          'org.bluez.GattCharacteristic1',
          'ReadValue',
          [
            DBusDict.stringVariant({'offset': DBusUint16(6)}),
          ],
          replySignature: DBusSignature('ay'));
      expect(String.fromCharCodes(response.returnValues[0].asByteArray()), 'Labs');
    });

    test('sends notifications only while subscribed', () async {
      final object = bluez.adapter.applicationObject(txPath);
      final subscriptions = <BleSubscription>[];
      final values = <DBusValue>[];
      final subscriptionListener = peripheral.subscriptions.listen(subscriptions.add);
      final signalListener = object.propertiesChanged.listen((signal) {
        final value = signal.changedProperties['Value'];
        if (value != null) {
          values.add(value);
        }
      });
      await _settle();

      expect(await peripheral.notify(tx, Uint8List.fromList([9])), isFalse);

      await object.callMethod('org.bluez.GattCharacteristic1', 'StartNotify', [], replySignature: DBusSignature(''));
      expect(peripheral.isNotifying(tx), isTrue);
      expect(await peripheral.notify(tx, Uint8List.fromList([4, 5])), isTrue);
      await _settle();

      await object.callMethod('org.bluez.GattCharacteristic1', 'StopNotify', [], replySignature: DBusSignature(''));
      await _settle();
      await subscriptionListener.cancel();
      await signalListener.cancel();

      expect(values, [
        DBusArray.byte([4, 5])
      ]);
      expect(subscriptions.map((s) => (s.characteristic, s.notifying)), [(tx, true), (tx, false)]);
    });

    test('reports the advertisement being released', () async {
      final released = peripheral.released.first;
      await bluez.adapter.releaseAdvertisement();
      await released;
      expect(peripheral.isAdvertising, isFalse);

      await peripheral.stop();
      expect(bluez.adapter.unregisteredAdvertisements, isEmpty);
      expect(bluez.adapter.unregisteredApplications, [DBusObjectPath('/dbus_wifi/ble/app')]);
    });

    test('stops and can start again', () async {
      await peripheral.stop();
      expect(peripheral.isRunning, isFalse);
      expect(bluez.adapter.unregisteredAdvertisements, [DBusObjectPath('/dbus_wifi/ble/advertisement')]);
      expect(() => peripheral.notify(tx, Uint8List(0)), throwsArgumentError);

      await peripheral.start(
        services: [
          BleGattService(uuid: _serviceUuid, characteristics: [rx]),
        ],
        advertisement: const BleAdvertisement(localName: 'Frame-1234'),
      );
      expect(peripheral.isRunning, isTrue);
    });

    test('refuses to start twice', () async {
      await expectLater(
        peripheral.start(services: [], advertisement: const BleAdvertisement()),
        throwsStateError,
      );
    });
  });
}

Future<void> _settle() => Future.delayed(const Duration(milliseconds: 50));
