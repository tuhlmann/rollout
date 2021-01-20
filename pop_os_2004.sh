#!/bin/bash

source ./rollout.sh

echo "Installing on POP OS! 20.04"

echo "Updating current system to latest"
sudo apt update
sudo apt upgrade -y

echo "Start installing"

add_packages "build-essential apt-transport-https ca-certificates curl \
     software-properties-common git-core git git-lfs gnome-tweaks synaptic \
     dconf-editor ffmpeg \
     vim vim-gui-common vim-gtk htop python-pycurl language-pack-de \
     ubuntu-restricted-extras ack-grep exuberant-ctags ruby rake \
     gconf-editor dconf-editor gnupg-agent"

#if ! repository_installed "mozillateam/firefox-next"
#then
#  echo "Add firefox-next repo"
#  add_repository "mozillateam/firefox-next"
#  sudo apt update
#  sudo apt upgrade
#fi

# Get the latest LibreOffice version
if ! repository_installed "libreoffice"
then
  echo "Add libreoffice repo"
  add_repository "libreoffice"
  sudo apt update
  sudo apt upgrade -y
fi

gsettings set org.gnome.mutter edge-tiling false

# Enable Snaps on Pop OS
if ! package_installed "snapd"
then
 add_packages "snapd"
 sudo snap install snap-store
fi

# Variety Wallpaper Switcher
if ! package_installed "variety"
then
  echo "Install variety slideshow"
  add_repository "peterlevi/ppa"
  sudo apt update
  add_packages "variety"
fi

# Docker
if ! package_installed "docker-ce"
then
  echo "Install latest official Docker"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
  sudo apt update

  sudo apt install -y docker-ce docker-ce-cli containerd.io
  sudo usermod -aG docker ${USER}
  echo "172.17.0.1      host.docker.internal" | sudo tee -a /etc/hosts > /dev/null 2>&1
fi
