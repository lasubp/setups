#!/bin/bash

# Install Ansible

echo "Ansible will be installed via pipx"

echo "installing pipx"
sudo dnf install pipx

echo "Verifieing pipx is in the PATH"
pipx ensurepath

echo "Installing Ansible"
pipx install --include-deps ansible

echo "Installing agrcomplete for ansible"
pipx inject --include-apps ansible argcomplete
