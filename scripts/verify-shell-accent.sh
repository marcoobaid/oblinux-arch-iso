#!/usr/bin/env bash
# Verify the stock GNOME Shell accent mechanism on a built live/installed
# OBLinux system. Run as the logged-in desktop user, never with sudo.

set -uo pipefail

user_theme_uuid="user-theme@gnome-shell-extensions.gcampax.github.com"
enabled="$(gsettings get org.gnome.shell enabled-extensions 2>&1)"
accent="$(gsettings get org.gnome.desktop.interface accent-color 2>&1)"

echo "== OBLinux stock GNOME Shell verification =="
echo "Enabled extensions: $enabled"
echo "Current accent: $accent"

case "$enabled" in
  *"$user_theme_uuid"*)
    echo "FAIL: User Themes is enabled; Shell accent may be hard-coded."
    exit 1
    ;;
esac

case "$accent" in
  "'blue'"|"'teal'"|"'green'"|"'yellow'"|"'orange'"|"'red'"|"'pink'"|"'purple'"|"'slate'")
    echo "PASS: stock Shell is active with a supported GNOME accent."
    echo "Still change the accent in Settings and confirm Quick Settings and"
    echo "the power dialog update visually."
    ;;
  *)
    echo "FAIL: unexpected GNOME accent value: $accent"
    exit 1
    ;;
esac
