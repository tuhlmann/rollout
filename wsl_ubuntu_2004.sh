#!/bin/bash

# The system user
THE_USER=$(whoami)

source ./rollout.sh

echo "Installing on Ubuntu 20.04 in WSL 2 for user $THE_USER"

echo "Updating current system to latest"
upgrade_system

echo "Start installing"

add_packages "build-essential apt-transport-https ca-certificates curl \
     software-properties-common git-core git git-lfs ffmpeg \
     vim vim-gui-common vim-gtk htop python-pycurl language-pack-de \
     ack-grep exuberant-ctags ruby rake"

# Docker
if ! package_installed "docker-ce"
then
  echo "Install latest official Docker"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
  sudo apt update

  add_packages "docker-ce docker-ce-cli containerd.io"
  sudo usermod -aG docker ${USER}
#  echo "172.17.0.1      host.docker.internal" | sudo tee -a /etc/hosts > /dev/null 2>&1
fi

if ! command_installed "docker-compose"
then
  sudo curl -L "https://github.com/docker/compose/releases/download/2.3.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi

if [ ! -d "$HOME/.sdkman" ]
then
  echo "Install OpenJDK 8.0.265"
  curl -s "https://get.sdkman.io" | bash
  source $HOME/.sdkman/bin/sdkman-init.sh
  sdk install java 8.0.282-open
fi

if ! command_installed "node"
then
  echo "Install NVM and then latest node"
  wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  source $HOME/.nvm/nvm.sh
  nvm install --lts
fi

# Setup /ewu dir
if [ ! -d "/ewu" ]
then
  sudo mkdir /ewu
  sudo chown $THE_USER.$THE_USER /ewu
fi
