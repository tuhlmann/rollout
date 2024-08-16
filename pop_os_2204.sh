#!/bin/bash

# The system user
THE_USER=$(whoami)

source ./rollout.sh

echo "Installing on POP OS! 22.04 for user $THE_USER"

echo "Updating current system to latest"
upgrade_system

echo "Start installing"

add_packages "build-essential apt-transport-https ca-certificates curl \
     software-properties-common git-core git git-lfs gnome-tweaks synaptic \
     dconf-editor ffmpeg \
     vim vim-gui-common vim-gtk htop language-pack-de \
     ubuntu-restricted-extras ack-grep exuberant-ctags ruby rake \
     gnupg-agent variety gnome-sushi restic"

gsettings set org.gnome.mutter edge-tiling false

# Keybase
if ! package_installed "keybase"
then
  curl --remote-name https://prerelease.keybase.io/keybase_amd64.deb
  sudo apt install -y ./keybase_amd64.deb
  run_keybase
  rm ./keybase_amd64.deb
fi

# Docker
if ! package_installed "docker-ce"
then
  echo "Install latest official Docker"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null  
  sudo apt update

  add_packages "docker-ce docker-ce-cli containerd.io"
  sudo usermod -aG docker ${USER}
  echo "172.17.0.1      host.docker.internal" | sudo tee -a /etc/hosts > /dev/null 2>&1
fi

#if ! command_installed "docker-compose"
#then
#  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#  sudo chmod +x /usr/local/bin/docker-compose
#fi

#if [ ! -d "$HOME/.sdkman" ]
#then
#  echo "Install OpenJDK 11"
#  curl -s "https://get.sdkman.io" | bash
#  source $HOME/.sdkman/bin/sdkman-init.sh
#  sdk install java 11.0.11-open
#  sdk install maven 3.8.1
#fi

if ! package_installed "syncthing"
then
  echo "Install Syncthing"
  sudo curl -s -o /usr/share/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
  echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
  printf "Package: *\nPin: origin apt.syncthing.net\nPin-Priority: 990\n" | sudo tee /etc/apt/preferences.d/syncthing
  sudo apt update
  add_packages "syncthing"
fi

if ! command_installed "node"
then
  echo "Install NVM and then latest node"
  wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
  source $HOME/.nvm/nvm.sh
  nvm install --lts
fi

if ! package_installed "sublime-text"
then
  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
  echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
  sudo apt update
  add_packages "sublime-text"
fi

if ! package_installed "darktable"
then
  echo 'deb http://download.opensuse.org/repositories/graphics:/darktable/xUbuntu_22.04/ /' | sudo tee /etc/apt/sources.list.d/graphics:darktable.list
  curl -fsSL https://download.opensuse.org/repositories/graphics:darktable/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/graphics_darktable.gpg > /dev/null
  sudo apt update
  add_packages "darktable"
fi

if ! package_installed "enpass"
then
  wget -O - https://apt.enpass.io/keys/enpass-linux.key | sudo apt-key add -
  echo 'deb https://apt.enpass.io/ stable main' | sudo tee /etc/apt/sources.list.d/enpass.list
  sudo apt update
  add_packages "enpass"  
fi

if ! package_installed "brave-browser"
then
  curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  sudo apt update
  add_packages "brave-browser"  
fi

if ! package_installed "pgadmin4-desktop"
then
  sudo curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add
  sudo sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list'
  sudo apt update
  add_packages "pgadmin4-desktop"
fi

#if ! package_installed "howdy"
#then
#  add_repository "boltgolt/howdy"
#  sudo apt update
#  add_packages howdy v4l-utils
#fi

# Enable Snaps on Pop OS
if ! package_installed "snapd"
then
 add_packages "snapd" 
fi

# Set clock to local time to play nice with Windows
timedatectl set-local-rtc 1 --adjust-system-clock

# Set Numpad to be uses as on Windows
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:none', 'numpad:microsoft']"

# Lower barrier for low mouse/keyboard battery
gsettings set org.gnome.settings-daemon.plugins.power percentage-low 4

# Install flatpak stuff
flatpak install --noninteractive flathub com.syntevo.SmartGit

flatpak install --noninteractive flathub io.dbeaver.DBeaverCommunity

flatpak install --noninteractive flathub me.hyliu.fluentreader

flatpak install --noninteractive flathub com.gitlab.newsflash

flatpak install --noninteractive flathub com.github.johnfactotum.Foliate

flatpak install --noninteractive flathub io.typora.Typora

flatpak install --noninteractive flathub com.slack.Slack

flatpak install --noninteractive flathub net.cozic.joplin_desktop

flatpak install --noninteractive flathub org.filezillaproject.Filezilla

flatpak install --noninteractive flathub org.videolan.VLC

flatpak install --noninteractive flathub com.spotify.Client

flatpak install --noninteractive flathub org.gimp.GIMP

flatpak install --noninteractive flathub org.kde.gwenview

# TODO Snap Store stuff, only successful after relogin/reboot
sudo snap install snap-store
sudo snap install shutter
sudo snap install nodemailerapp
sudo snap install p3x-onenote
# sudo snap install superproductivity
sudo snap install vokoscreen-ng

# Setup /ewu dir
if [ ! -d "/ewu" ]
then
  sudo mkdir /ewu
  sudo chown $THE_USER.$THE_USER /ewu
fi

# Disable printer auto discovery
sudo systemctl stop cups-browsed
sudo systemctl disable cups-browsed
