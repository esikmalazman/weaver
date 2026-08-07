#!/bin/bash
set -euo pipefail

# Xcode 27 replaced Simulator.app with DeviceHub.app.
# SweetPad still runs `open -a Simulator`; this shim forwards that to Device Hub.

SHIM_ROOT="${1:-$HOME/Applications/Simulator.app}"
DEVICE_HUB="/Applications/Xcode-beta.app/Contents/Applications/DeviceHub.app"

if [[ ! -d "$DEVICE_HUB" ]]; then
  echo "Device Hub not found at: $DEVICE_HUB" >&2
  echo "Install Xcode 27 beta or update DEVICE_HUB in this script." >&2
  exit 1
fi

rm -rf "$SHIM_ROOT"
osacompile -o "$SHIM_ROOT" -e 'tell application "DeviceHub" to activate'

echo "Installed Simulator shim at: $SHIM_ROOT"
echo "Test with: open -a Simulator"
