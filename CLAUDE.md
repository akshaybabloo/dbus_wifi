# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dart library and CLI for managing Wi-Fi networks (NetworkManager) and running Bluetooth LE peripherals (BlueZ) on Linux via D-Bus. Published as `dbus_wifi` on pub.dev. Linux-only (`platforms: linux`).

## Commands

- **Get dependencies:** `dart pub get`
- **Run CLI:** `dart run bin/dbus_wifi.dart` (Wi-Fi) or `dart run bin/dbus_bluetooth.dart` (Bluetooth)
- **Analyze:** `dart analyze`
- **Format:** `dart format .` (page width configured to 120 in `analysis_options.yaml`)
- **Run tests:** `dart test` (Bluetooth tests run against a fake BlueZ on an in-process `DBusServer`, no hardware needed)
- **BLE smoke test:** `dart run example/ble_peripheral.dart` (needs a real adapter; check with `busctl tree org.bluez` or nRF Connect)
- **Regenerate D-Bus interfaces:** `just generate` (requires `dart-dbus` globally activated)

## Architecture

The library wraps NetworkManager's D-Bus API into a single `DbusWifi` class (`lib/dbus_wifi.dart`) that provides scan, connect, disconnect, status, saved networks, and forget operations.

### Key layers

1. **D-Bus interface bindings** (`lib/interfaces/`) — auto-generated from XML introspection files in `interfaces/` using `dart-dbus generate-remote-object` (interfaces we call) and `dart-dbus generate-object` (interfaces we export, e.g. BlueZ GATT objects and ObjectManager). Do not hand-edit these files or hand-write interfaces; add the official XML to `interfaces/`, add a line to `just generate`, and subclass the generated class.
2. **Domain model** (`lib/models/wifi_network.dart`) — `WifiNetwork` value class holding SSID, MAC, strength, security type, and mode.
3. **Core library** (`lib/dbus_wifi.dart`) — `DbusWifi` class and `ConnectionStatus` enum. All NetworkManager interaction goes through `OrgFreedesktopNetworkManager` (Wi-Fi device ops) and `OrgFreedesktopNetworkManagerSettings` (saved connections). The class discovers the Wi-Fi device by iterating devices and matching `DeviceType == 2`.
4. **Bluetooth** (`lib/dbus_bluetooth.dart`, `lib/bluetooth/`, `lib/models/ble_*.dart`) — separate entrypoint so Wi-Fi imports don't change. `DbusBluetooth` wraps `org.bluez.Adapter1`/`Device1` (found via BlueZ's ObjectManager). `BlePeripheral` exports a GATT application (`GattApplicationObject` root, `GattServiceObject`, `GattCharacteristicObject`) and an `AdvertisementObject`, then calls `GattManager1.RegisterApplication` and `LEAdvertisingManager1.RegisterAdvertisement`. The objects subclass the generated `lib/interfaces/*_object.dart` classes and override `interfacesAndProperties`, `getProperty` and `getAllProperties` themselves, because the generated `getAllProperties` double-wraps variants.
   - `GattApplicationObject` implements `GetManagedObjects` for its own children only: the dbus package's built-in `isObjectManager` reports every object on the connection, which would leak the advertisement into the GATT database.
   - Handler exceptions become `org.bluez.Error.*` replies (`BleGattException` picks the name), so a bad write never crashes the host.
5. **CLI** (`bin/dbus_wifi.dart`, `bin/dbus_bluetooth.dart`) — interactive menus using `dart_console`. Registered as the `dbus-wifi` and `dbus-bluetooth` executables in `pubspec.yaml`. `dart_console` needs a real TTY (it queries the cursor position), so piping input into them doesn't work.

### Security type detection

`_determineSecurityType` inspects RSN/WPA flag bitmasks to classify networks (SAE, WPA-EAP, WPA-PSK, OWE, etc.). When modifying this, reference the NetworkManager AP flag constants.
