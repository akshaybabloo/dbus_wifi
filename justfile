# use PowerShell instead of sh:
set windows-shell := ["pwsh.exe", "-c"]

default: (help)

# Print this help message
@help:
    echo "run 'just list' to list targets"
    echo "more information can be found at  at http://just.systems/"
    just list

# List the recipes and descriptions
list:
    @just --list

generate:
    dart pub global activate dbus
    dart-dbus generate-remote-object ./interfaces/org.freedesktop.NetworkManager.xml -o lib/interfaces/wifi_remote_object.dart
    dart-dbus generate-remote-object ./interfaces/org.freedesktop.NetworkManager.Settings.xml -o lib/interfaces/nm_settings_remote_object.dart
    # dart-dbus generate-remote-object ./interfaces/org.freedesktop.DBus.Properties.xml -o lib/interfaces/dbus_properties_remote_object.dart
    dart-dbus generate-remote-object ./interfaces/org.bluez.Adapter1.xml -o lib/interfaces/bluez_adapter_remote_object.dart
    dart-dbus generate-remote-object ./interfaces/org.bluez.Device1.xml -o lib/interfaces/bluez_device_remote_object.dart
    dart-dbus generate-remote-object ./interfaces/org.bluez.GattManager1.xml -o lib/interfaces/bluez_gatt_manager_remote_object.dart
    dart-dbus generate-remote-object ./interfaces/org.bluez.LEAdvertisingManager1.xml -o lib/interfaces/bluez_advertising_manager_remote_object.dart
    dart-dbus generate-object ./interfaces/org.bluez.GattService1.xml -o lib/interfaces/bluez_gatt_service_object.dart
    dart-dbus generate-object ./interfaces/org.bluez.GattCharacteristic1.xml -o lib/interfaces/bluez_gatt_characteristic_object.dart
    dart-dbus generate-object ./interfaces/org.bluez.LEAdvertisement1.xml -o lib/interfaces/bluez_advertisement_object.dart
    dart-dbus generate-object ./interfaces/org.freedesktop.DBus.ObjectManager.xml -o lib/interfaces/object_manager_object.dart
    dart format lib/interfaces/bluez_*.dart lib/interfaces/object_manager_object.dart
