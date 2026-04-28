#!/bin/bash

# System Upgrade
sudo dnf upgrade -y

# System Config
# Optimize DNF package manager for faster downloads and efficient updates
backup_file "/etc/dnf/dnf.conf"
echo "max_parallel_downloads=10" | tee -a /etc/dnf/dnf.conf > /dev/null
sudo dnf -y install dnf-plugins-core

# Enable RPM Fusion repositories to access additional software packages and codecs
sudo dnf install --nogpgcheck https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm
sudo dnf install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm
# RHEL clones have a alternatives step (for Alma and Rocky, versions 8 to 10)
sudo /usr/bin/crb enable

# Create necessary directories
mkdir -p "$HOME/.config"
zshplugins=$HOME/.config/zsh/plugins/
mkdir -p $zshplugins/
mkdir -p $HOME/.config/tmux
mkdir -p $HOME/dotfiles

# App Install
# Install essential applications
sudo dnf install -y btop htop rsync tmux wget curl

# Install development tools and utilities
sudo dnf install -y git
sudo dnf install -y zsh

# Download ZSH Plugins
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git $zshplugins/zsh-autosuggestions
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git $zshplugins/zsh-syntax-highlighting

# Install starship prompt
# color_echo "blue" "Installing starship prompt..."
# curl -sS https://starship.rs/install.sh | sh

# Download tmux theme pack
git clone --depth 1 https://github.com/jimeh/tmux-themepack.git $HOME/.config/tmux/tmux-themepack

# Downloading dotfiles
git clone --depth 1 https://github.com/lasubp/dotfiles.git $HOME/dotfiles

# STOW
ln -s $HOME/dotfiles/.config/zsh/aliases.zsh $HOME/.config/zsh/aliases.zsh
ln -s $HOME/dotfiles/.config/tmux/tmux.conf $HOME/.config/tmux/tmux.conf

# Setup ZSH as default shell
chsh -s $(which zsh) $USER
