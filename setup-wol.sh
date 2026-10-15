#!/bin/bash

# --- Fill device name ---
NIC="enp6s0"

# === script execution. DO NOT CHANGE ===

# --- Permissions check ---

# Required NetworkManager permissions
REQUIRED_PERMISSIONS=(
    "org.freedesktop.NetworkManager.settings.modify.system"
    "org.freedesktop.NetworkManager.network-control"
)

# Get NetworkManager permissions for the current execution context
declare -A NM_PERMISSIONS

while IFS=: read -r permission value; do
    NM_PERMISSIONS["$permission"]="$value"
done < <(nmcli -t -f PERMISSION,VALUE general permissions)

# Check all required permissions before doing anything
for permission in "${REQUIRED_PERMISSIONS[@]}"; do
    if [[ "${NM_PERMISSIONS[$permission]}" != "yes" ]]; then
        echo "ERROR: Missing NetworkManager permission:"
        echo "       $permission"
        echo
        echo "Current NetworkManager permissions:"
        nmcli general permissions
        exit 1
    fi
done

# Active connection
CONNECTION=$(nmcli -g GENERAL.CONNECTION device show $NIC)

# Check if connecton exist
if [ -z "$CONNECTION" ]; then
    echo "ERROR: No active connection found for ens192."
    exit 1
fi

echo "Connection: $CONNECTION"

# Set WoL via nmcli for the active connection
nmcli connection modify "$CONNECTION" 802-3-ethernet.wake-on-lan magic

# Verify the setting
nmcli connection show "$CONNECTION" | grep wake-on-lan

# Reactivate the connection to apply
nmcli connection up "$CONNECTION"

echo "WOL setup on device $NIC"
echo "MAC: $(nmcli -g GENERAL.HWADDR device show $NIC | tr -d '\\')"
