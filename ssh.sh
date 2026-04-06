#!/bin/bash

# Setup script for SSH directory and essential files

# Define the .ssh directory path
SSH_DIR="$HOME/.ssh"

# Check if the .ssh directory already exists
if [ ! -d "$SSH_DIR" ]; then
    echo "Creating .ssh directory at $SSH_DIR..."
    mkdir -m 700 "$SSH_DIR"
    echo ".ssh directory created with permissions 700."
else
    echo ".ssh directory already exists at $SSH_DIR. Ensuring correct permissions."
    chmod 700 "$SSH_DIR"
fi

# Create authorized_keys file if it doesn't exist and set permissions
AUTHORIZED_KEYS_FILE="$SSH_DIR/authorized_keys"
if [ ! -f "$AUTHORIZED_KEYS_FILE" ]; then
    echo "Creating authorized_keys file at $AUTHORIZED_KEYS_FILE..."
    touch "$AUTHORIZED_KEYS_FILE"
    chmod 600 "$AUTHORIZED_KEYS_FILE"
    echo "authorized_keys file created with permissions 600."
else
    echo "authorized_keys file already exists. Ensuring correct permissions."
    chmod 600 "$AUTHORIZED_KEYS_FILE"
fi

# Create config file if it doesn't exist and set permissions (optional)
CONFIG_FILE="$SSH_DIR/config"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating config file at $CONFIG_FILE..."
    touch "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"
    echo "config file created with permissions 600."
else
    echo "config file already exists. Ensuring correct permissions."
    chmod 600 "$CONFIG_FILE"
fi

echo "SSH directory and essential files setup complete."
echo "You can now generate SSH keys using 'ssh-keygen' if needed."