#!/bin/bash

VERSION=1.0

DEBUG_LOG="rollout.log"

echo "Rollout, Version $VERSION, playing file $PLAYBOOK"
echo "Rollout, Version $VERSION, playing file $PLAYBOOK" > $DEBUG_LOG

DRY_RUN=false
while getopts ":t" flag
do
    case "${flag}" in
        t)
          echo "Running in Dry Run mode. Not changing anything." 
          DRY_RUN=true
          ;;
        \?) 
          echo "<rollout script> [-t]"
          echo "  -t dry run, don't change anything"
          exit 1
          ;;
    esac
done

#if "$DRY_RUN"
#if ! "$DRY_RUN"

# These are function definitions used within the playbook

function upgrade_system {
  if ! "$DRY_RUN"; then
    sudo apt update
    sudo apt upgrade -y
  else
    echo "Dry Run, not updating the system"  
  fi
}

# Checks if a certain deb package is installed
function package_installed {
  dpkg-query -l $1 > /dev/null 2>&1

  return $?
}

function filter_not_installed_packages {
  local not_installed=""
  for package in $1
  do 
    printf "\nCheck if installed: $package" >> $DEBUG_LOG
    if ! package_installed "$package"
    then
      not_installed="$not_installed $package"
    fi
  done
  printf "\nNot installed packages: $not_installed" >> $DEBUG_LOG
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
      if ! "$DRY_RUN"; then
        sudo apt install -y $not_installed
      fi
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
    if ! "$DRY_RUN"; then
      sudo add-apt-repository -y ppa:$1
    fi  
    return 0
  fi

  printf "ppa:$1 already exists\n"
  return 1
}

function command_installed {
  command -v $1 &> /dev/null
  return $?
}