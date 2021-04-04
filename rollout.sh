#!/bin/bash

VERSION=1.0

echo "Rollout, Version $VERSION, playing file $PLAYBOOK"

# These are function definitions used within the playbook

# Checks if a certain deb package is installed
function package_installed {
  dpkg-query -l $1 > /dev/null 2>&1
  return $?
}

function filter_not_installed_packages {
  local not_installed=""
  for package in $1
  do 
    if ! package_installed "$package"
    then
      not_installed="$not_installed $package"
    fi
  done
  printf "$not_installed"
}

# TODO: Filter list of packages and remove those already installed 
function add_packages {
  for pkg in "$@"
  do
    local not_installed=$(filter_not_installed_packages "$pkg")
    if [[ ! -z "$not_installed" ]]
    then
      printf "Installing packages:\n$not_installed\n"
      sudo apt install -y $not_installed
    else
      printf "All packages already installed:\n$pkg\n"  
    fi
  done
}

function repository_installed {
  grep -h "^deb.*$1" /etc/apt/sources.list.d/* > /dev/null 2>&1
  return $?
}

function add_repository {
  grep -h "^deb.*$1" /etc/apt/sources.list.d/* > /dev/null 2>&1
  if [ $? -ne 0 ]
  then
    printf "Adding ppa:\n$1\n"
    sudo add-apt-repository -y ppa:$1
    return 0
  fi

  printf "ppa:$1 already exists\n"
  return 1
}

function command_installed {
  command -v $1 &> /dev/null
  return $?
}