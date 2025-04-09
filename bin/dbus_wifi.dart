import 'package:dart_console/dart_console.dart';
import 'package:dbus_wifi/dbus_wifi.dart';
import 'package:dbus_wifi/models/wifi_network.dart';

void main() async {
  final wifi = DbusWifi();

  if (await wifi.hasWifiDevice) {
    print('Wi-Fi device found. Scanning for networks...');
    final results = await wifi.search(timeout: Duration(seconds: 7));
    print('Found ${results.length} networks:\n');
    printToTable(results);

    // Select the ID from the table to connect
    final console = Console();
    console.writeLine('Select the ID of the network to connect:');
    var input = console.readLine();
    while (input != null && input.isEmpty) {
      console.writeLine('Please enter a valid ID:');
      input = console.readLine();
    }

    var selectedId = int.tryParse(input!);
    while (selectedId == null || selectedId <= 0 || selectedId > results.length) {
      console.writeLine('Invalid selection. Please enter a valid ID:');
      input = console.readLine();
      selectedId = int.tryParse(input!);
    }

    final selectedNetwork = results[selectedId - 1];

    console.writeLine('Enter the password for ${selectedNetwork.ssid}:');
    String? password = console.readLine();
    while (password != null && password.isEmpty) {
      console.writeLine('Password cannot be empty. Please enter the password:');
      password = console.readLine();
    }

    console.writeLine('Connecting to ${selectedNetwork.ssid}...');
    wifi.connect(selectedNetwork, password!);

    // Here you would add the code to connect to the selected network
  } else {
    print('No Wi-Fi device found.');
  }

  await wifi.close();
}

/// Prints the list of Wi-Fi networks in a table format
void printToTable(List<WifiNetwork> networks) {
  var data = <List<String>>[];
  for (var i = 0; i < networks.length; i++) {
    final network = networks[i];
    data.add([
      (i + 1).toString(),
      network.ssid,
    ]);
  }
  final table = Table()
    ..insertColumn(header: 'Select', alignment: TextAlignment.center)
    ..insertColumn(header: 'SSID', alignment: TextAlignment.left)
    ..insertRows(data)
    ..borderStyle = BorderStyle.square
    ..borderColor = ConsoleColor.brightBlue
    ..borderType = BorderType.vertical
    ..headerStyle = FontStyle.bold;
  print(table);
}
