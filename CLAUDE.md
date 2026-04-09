# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dart library and CLI for managing Wi-Fi networks on Linux via D-Bus (NetworkManager). Published as `dbus_wifi` on pub.dev. Linux-only (`platforms: linux`).

## Commands

- **Get dependencies:** `dart pub get`
- **Run CLI:** `dart run bin/dbus_wifi.dart`
- **Analyze:** `dart analyze`
- **Format:** `dart format .` (page width configured to 120 in `analysis_options.yaml`)
- **Run tests:** `dart test` (no tests exist yet)
- **Regenerate D-Bus interfaces:** `just generate` (requires `dart-dbus` globally activated)

## Architecture

The library wraps NetworkManager's D-Bus API into a single `DbusWifi` class (`lib/dbus_wifi.dart`) that provides scan, connect, disconnect, status, saved networks, and forget operations.

### Key layers

1. **D-Bus interface bindings** (`lib/interfaces/`) — auto-generated from XML introspection files in `interfaces/` using `dart-dbus generate-remote-object`. Do not hand-edit these files; re-run `just generate` instead.
2. **Domain model** (`lib/models/wifi_network.dart`) — `WifiNetwork` value class holding SSID, MAC, strength, security type, and mode.
3. **Core library** (`lib/dbus_wifi.dart`) — `DbusWifi` class and `ConnectionStatus` enum. All NetworkManager interaction goes through `OrgFreedesktopNetworkManager` (Wi-Fi device ops) and `OrgFreedesktopNetworkManagerSettings` (saved connections). The class discovers the Wi-Fi device by iterating devices and matching `DeviceType == 2`.
4. **CLI** (`bin/dbus_wifi.dart`) — interactive menu using `dart_console`. Registered as the `dbus-wifi` executable in `pubspec.yaml`.

### Security type detection

`_determineSecurityType` inspects RSN/WPA flag bitmasks to classify networks (SAE, WPA-EAP, WPA-PSK, OWE, etc.). When modifying this, reference the NetworkManager AP flag constants.
