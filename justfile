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
    # dart-dbus generate-remote-object ./interfaces/org.freedesktop.DBus.Properties.xml -o lib/interfaces/dbus_properties_remote_object.dart
