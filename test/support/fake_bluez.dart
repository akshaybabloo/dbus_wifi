import 'package:dbus/dbus.dart';

const adapterPath = '/org/bluez/hci0';

/// A minimal stand-in for bluetoothd, exported on a private bus as `org.bluez`
class FakeBluez {
  final DBusClient client;
  late final FakeAdapter adapter;
  final _root = DBusObject(DBusObjectPath('/'), isObjectManager: true);

  FakeBluez(this.client);

  Future<void> start() async {
    await client.requestName('org.bluez');
    adapter = FakeAdapter(client);
    await client.registerObject(_root);
    await client.registerObject(adapter);
  }

  Future<FakeDevice> addDevice(String address, {bool connected = false, int? rssi}) async {
    final device = FakeDevice(address, connected: connected, rssi: rssi);
    await client.registerObject(device);
    return device;
  }

  Future<void> removeDevice(FakeDevice device) => client.unregisterObject(device);
}

class FakeAdapter extends DBusObject {
  final DBusClient bus;
  bool powered = true;
  String alias = 'fake-adapter';

  String? applicationOwner;
  DBusObjectPath? application;
  Map<DBusObjectPath, Map<String, Map<String, DBusValue>>>? applicationObjects;
  final unregisteredApplications = <DBusObjectPath>[];

  String? advertisementOwner;
  DBusObjectPath? advertisement;
  Map<String, DBusValue>? advertisementProperties;
  final unregisteredAdvertisements = <DBusObjectPath>[];

  bool discovering = false;
  final discoveryFilters = <Map<String, DBusValue>>[];

  /// Devices that appear once discovery starts
  final nearby = <FakeDevice>[];

  FakeAdapter(this.bus) : super(DBusObjectPath(adapterPath));

  Map<String, DBusValue> get _adapterProperties => {
        'Address': DBusString('00:11:22:33:44:55'),
        'Alias': DBusString(alias),
        'Powered': DBusBoolean(powered),
      };

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.bluez.Adapter1': _adapterProperties,
        'org.bluez.GattManager1': {},
        'org.bluez.LEAdvertisingManager1': {},
      };

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    final value = interface == 'org.bluez.Adapter1' ? _adapterProperties[name] : null;
    return value == null ? DBusMethodErrorResponse.unknownProperty() : DBusGetPropertyResponse(value);
  }

  @override
  Future<DBusMethodResponse> setProperty(String interface, String name, DBusValue value) async {
    if (interface == 'org.bluez.Adapter1' && name == 'Powered') {
      powered = value.asBoolean();
      return DBusMethodSuccessResponse();
    }
    if (interface == 'org.bluez.Adapter1' && name == 'Alias') {
      alias = value.asString();
      return DBusMethodSuccessResponse();
    }
    return DBusMethodErrorResponse.propertyReadOnly();
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    switch ((methodCall.interface, methodCall.name)) {
      case ('org.bluez.GattManager1', 'RegisterApplication'):
        final path = methodCall.values[0].asObjectPath();
        applicationOwner = methodCall.sender;
        application = path;
        applicationObjects = await DBusRemoteObjectManager(
          bus,
          name: methodCall.sender!,
          path: path,
        ).getManagedObjects();
        return DBusMethodSuccessResponse();
      case ('org.bluez.GattManager1', 'UnregisterApplication'):
        unregisteredApplications.add(methodCall.values[0].asObjectPath());
        return DBusMethodSuccessResponse();
      case ('org.bluez.LEAdvertisingManager1', 'RegisterAdvertisement'):
        final path = methodCall.values[0].asObjectPath();
        advertisementOwner = methodCall.sender;
        advertisement = path;
        advertisementProperties = await DBusRemoteObject(
          bus,
          name: methodCall.sender!,
          path: path,
        ).getAllProperties('org.bluez.LEAdvertisement1');
        return DBusMethodSuccessResponse();
      case ('org.bluez.LEAdvertisingManager1', 'UnregisterAdvertisement'):
        unregisteredAdvertisements.add(methodCall.values[0].asObjectPath());
        return DBusMethodSuccessResponse();
      case ('org.bluez.Adapter1', 'SetDiscoveryFilter'):
        discoveryFilters.add(methodCall.values[0].asStringVariantDict());
        return DBusMethodSuccessResponse();
      case ('org.bluez.Adapter1', 'StartDiscovery'):
        discovering = true;
        for (final device in nearby) {
          await bus.registerObject(device);
        }
        return DBusMethodSuccessResponse();
      case ('org.bluez.Adapter1', 'StopDiscovery'):
        discovering = false;
        return DBusMethodSuccessResponse();
      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }

  /// A remote handle on one of the registered application's objects, as bluetoothd would use it
  DBusRemoteObject applicationObject(DBusObjectPath path) => DBusRemoteObject(bus, name: applicationOwner!, path: path);

  /// Simulates bluetoothd dropping the advertisement
  Future<void> releaseAdvertisement() async {
    await DBusRemoteObject(
      bus,
      name: advertisementOwner!,
      path: advertisement!,
    ).callMethod('org.bluez.LEAdvertisement1', 'Release', [], replySignature: DBusSignature(''));
  }
}

class FakeDevice extends DBusObject {
  final String address;
  bool connected;
  final int? rssi;

  FakeDevice(this.address, {this.connected = false, this.rssi})
      : super(DBusObjectPath('$adapterPath/dev_${address.replaceAll(':', '_')}'));

  Map<String, DBusValue> get _properties => {
        'Address': DBusString(address),
        'Name': DBusString('Phone $address'),
        'Connected': DBusBoolean(connected),
        'Adapter': DBusObjectPath(adapterPath),
        if (rssi != null) 'RSSI': DBusInt16(rssi!),
      };

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {'org.bluez.Device1': _properties};

  @override
  Future<DBusMethodResponse> getAllProperties(String interface) async {
    return DBusGetAllPropertiesResponse(interface == 'org.bluez.Device1' ? _properties : {});
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface == 'org.bluez.Device1' && methodCall.name == 'Disconnect') {
      await setConnected(false);
      return DBusMethodSuccessResponse();
    }
    return DBusMethodErrorResponse.unknownMethod();
  }

  Future<void> setConnected(bool value) async {
    connected = value;
    await emitPropertiesChanged('org.bluez.Device1', changedProperties: {'Connected': DBusBoolean(value)});
  }
}
