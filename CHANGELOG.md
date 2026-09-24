
## 0.2.0

- Add DbusBluetooth for the BlueZ adapter: power, alias, address, device scanning, connected devices and connection changes
- Add BlePeripheral to run a GATT server and LE advertisement through BlueZ, with read, write and notify handlers
- Add BlueZ and ObjectManager interface XML and generated bindings
- Add dbus-bluetooth CLI to show adapter status, toggle power, set the name, scan for devices, list connected devices and run an echo peripheral
- Add BLE peripheral example and tests against a fake BlueZ on a private bus

## 0.1.0

- Update APIs to include DBus 0.8.0

## 0.0.7

- Add isWifiEnabled getter to check if Wi-Fi is currently enabled
- Add setWifiEnabled method to toggle Wi-Fi on or off
- Add toggle Wi-Fi option to CLI

## 0.0.6

- Update dependencies to latest versions

## 0.0.5

- Add getSavedNetworks method to list saved Wi-Fi networks
- Add forgetNetwork method to delete saved Wi-Fi networks
- Add NetworkManager Settings interface for managing saved connections
- Enhance CLI with options to view and forget saved networks
- Update documentation with examples for the new functionality

## 0.0.4

- Add disconnect method to disconnect from Wi-Fi networks
- Add getConnectionStatus method to check current connection status
- Improve error handling in connect method
- Add ConnectionStatus enum for better status representation
- Enhance CLI with menu-driven interface and additional functionality
- Expand documentation with more examples and API details

## 0.0.3

- Update README and example

## 0.0.2

- Add ability to connect to a Wi-Fi network
- Updated the executable to connect to a Wi-Fi network

## 0.0.1

- Initial version.
