import 'package:dart_console/dart_console.dart';
import 'package:dbus_wifi/dbus_wifi.dart';
import 'package:dbus_wifi/models/wifi_network.dart';

void main() async {
  final wifi = DbusWifi();
  final console = Console();

  if (await wifi.hasWifiDevice) {
    // Display menu
    console.writeLine('Wi-Fi Manager');
    console.writeLine('------------');
    console.writeLine('1. Scan for networks');
    console.writeLine('2. Check connection status');
    console.writeLine('3. Disconnect from network');
    console.writeLine('4. Exit');
    console.writeLine('');
    console.writeLine('Select an option:');

    var input = console.readLine();
    var option = int.tryParse(input ?? '');

    while (option != 4) {
      switch (option) {
        case 1:
          await scanAndConnect(wifi, console);
          break;
        case 2:
          await checkStatus(wifi, console);
          break;
        case 3:
          await disconnect(wifi, console);
          break;
        default:
          console.writeLine('Invalid option. Please try again.');
      }

      console.writeLine('');
      console.writeLine('Wi-Fi Manager');
      console.writeLine('------------');
      console.writeLine('1. Scan for networks');
      console.writeLine('2. Check connection status');
      console.writeLine('3. Disconnect from network');
      console.writeLine('4. Exit');
      console.writeLine('');
      console.writeLine('Select an option:');

      input = console.readLine();
      option = int.tryParse(input ?? '');
    }
  } else {
    console.writeLine('No Wi-Fi device found.');
  }

  await wifi.close();
}

/// Scans for networks and allows the user to connect to one
Future<void> scanAndConnect(DbusWifi wifi, Console console) async {
  console.writeLine('Scanning for networks...');
  final results = await wifi.search(timeout: Duration(seconds: 7));
  console.writeLine('Found ${results.length} networks:\n');
  printToTable(results);

  // Select the ID from the table to connect
  console.writeLine('Select the ID of the network to connect (or 0 to cancel):');
  var input = console.readLine();
  while (input != null && input.isEmpty) {
    console.writeLine('Please enter a valid ID:');
    input = console.readLine();
  }

  var selectedId = int.tryParse(input!);
  while (selectedId == null || selectedId < 0 || selectedId > results.length) {
    console.writeLine('Invalid selection. Please enter a valid ID:');
    input = console.readLine();
    selectedId = int.tryParse(input!);
  }

  // Return if user cancels
  if (selectedId == 0) {
    return;
  }

  final selectedNetwork = results[selectedId - 1];

  console.writeLine('Enter the password for ${selectedNetwork.ssid}:');
  String? password = console.readLine();
  while (password != null && password.isEmpty) {
    console.writeLine('Password cannot be empty. Please enter the password:');
    password = console.readLine();
  }

  console.writeLine('Connecting to ${selectedNetwork.ssid}...');
  try {
    await wifi.connect(selectedNetwork, password!);
    console.writeLine('Successfully connected to ${selectedNetwork.ssid}');
  } catch (e) {
    console.writeLine('Failed to connect: $e');
  }
}

/// Checks the current connection status
Future<void> checkStatus(DbusWifi wifi, Console console) async {
  console.writeLine('Checking connection status...');
  final status = await wifi.getConnectionStatus();

  switch (status['status']) {
    case ConnectionStatus.connected:
      final network = status['network'];
      if (network != null) {
        console.writeLine('Connected to: ${network.ssid}');
        console.writeLine('Signal strength: ${network.strength}%');
        console.writeLine('Security: ${network.security}');
      } else {
        console.writeLine('Connected to a network, but unable to get details.');
        if (status.containsKey('error')) {
          console.writeLine('Error: ${status['error']}');
        }
      }
      break;
    case ConnectionStatus.disconnected:
      console.writeLine('Not connected to any network.');
      break;
    case ConnectionStatus.connecting:
      console.writeLine('Currently connecting to a network...');
      break;
    case ConnectionStatus.failed:
      console.writeLine('Connection failed.');
      if (status.containsKey('error')) {
        console.writeLine('Error: ${status['error']}');
      }
      break;
    default:
      console.writeLine('Unknown status.');
  }
}

/// Disconnects from the current network
Future<void> disconnect(DbusWifi wifi, Console console) async {
  console.writeLine('Disconnecting from network...');
  final result = await wifi.disconnect();

  if (result) {
    console.writeLine('Successfully disconnected.');
  } else {
    console.writeLine('Failed to disconnect.');
  }
}

/// Prints the list of Wi-Fi networks in a table format
void printToTable(List<WifiNetwork> networks) {
  var data = <List<String>>[];
  for (var i = 0; i < networks.length; i++) {
    final network = networks[i];
    data.add([
      (i + 1).toString(),
      network.ssid,
      '${network.strength}%',
      network.security,
      network.mode,
    ]);
  }
  final table = Table()
    ..insertColumn(header: 'ID', alignment: TextAlignment.center)
    ..insertColumn(header: 'SSID', alignment: TextAlignment.left)
    ..insertColumn(header: 'Signal', alignment: TextAlignment.center)
    ..insertColumn(header: 'Security', alignment: TextAlignment.left)
    ..insertColumn(header: 'Mode', alignment: TextAlignment.left)
    ..insertRows(data)
    ..borderStyle = BorderStyle.square
    ..borderColor = ConsoleColor.brightBlue
    ..borderType = BorderType.vertical
    ..headerStyle = FontStyle.bold;
  print(table);
}
