#!/bin/bash

# System Upgrade
sudo dnf upgrade -y

# System Config
# Optimize DNF package manager for faster downloads and efficient updates
backup_file "/etc/dnf/dnf.conf"
echo "max_parallel_downloads=10" | tee -a /etc/dnf/dnf.conf > /dev/null
sudo dnf -y install dnf-plugins-core

# Replace Fedora Flatpak Repo with Flathub for better package management and apps stability
sudo dnf install -y flatpak
flatpak remote-delete fedora --force || true
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak repair
flatpak update

# Enable RPM Fusion repositories to access additional software packages and codecs
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf update @core -y


# App Install
# Install essential applications
sudo dnf install -y mc btop htop rsync tmux wget curl

# Create necessary directories
mkdir -p "$HOME/.config"
zshplugins=$HOME/.config/zsh/plugins/
mkdir -p $zshplugins/
mkdir -p $HOME/.config/tmux
mkdir -p $HOME/dotfiles

# Install development tools and utilities
sudo dnf install -y git
sudo dnf install -y lsd 
sudo dnf install -y zsh
sudo dnf install -y stow
sudo dnf install -y micro
sudo dnf copr enable lihaohong/yazi
sudo dnf install yazi

# Download ZSH Plugins
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git $zshplugins/zsh-autosuggestions
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git $zshplugins/zsh-syntax-highlighting

# Install starship prompt
# color_echo "blue" "Installing starship prompt..."
curl -sS https://starship.rs/install.sh | sh

# Download tmux theme pack
git clone --depth 1 https://github.com/jimeh/tmux-themepack.git $HOME/.config/tmux/tmux-themepack

# Downloading dotfiles
git clone --depth 1 https://github.com/lasubp/dotfiles.git $HOME/dotfiles

# STOW
cd $HOME/dotfiles
stow .

# Setup ZSH as default shell
chsh -s $(which zsh) $USER

### TODO: add mediacodecs setup from https://rpmfusion.org/Howto/Multimedia

# switch to full ffmpeg
sudo dnf swap ffmpeg-free ffmpeg --allowerasing

# install additional codec
# thiss will allow gsteamer framework and other multimedia software to use restricted codecs
sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

### Hardwre Accelerated codecs
#
## Intel (recent)
# sudo dnf install intel-media-driver
## Intel (older)
# sudo dnf install libva-intel-driver
#
## AMD (mesa)
# sudo dnf install mesa-va-drivers-freeworld
## for steam or alikes
# sudo dnf install mesa-va-drivers-freeworld.i686
#
## Nvidia
# sudo dnf install libva-nvidia-driver
## also 32 and 64 bit flovors cn be installed in one command as needed
# sudo dnf install libva-nvidia-driver.{i686,x86_64}

