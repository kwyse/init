#!/bin/sh

# Provisions the system for use
#
# This script will ready the system by:
#
#   * Downloading prerequisite packages
#   * Cloning dotfiles and creating symlinks
#
# It can be ran at any point during the logical provisioning process because
# it is idempotent. If running on a clean install, it will perform every
# step. If ran when any prerequisite packages are missing, it will install
# those. If ran just after it has already ran, it won't do anything.

PROJECTS_DIR=$HOME/projects
DOTFILES_REMOTE="https://github.com/kwyse/dotfiles"

function find_package_installer {
  case $(uname -s) in
    'Darwin')
      echo 'brew install' ;;
    'Linux')
      echo 'sudo pacman --sync --noconfirm' ;;
  esac
}

packages=(git)
installer=$(find_package_installer)

set -e

for package in "${packages[@]}"
do
  if ! [ -x "$(command -v $package)" ]; then
    echo "Installing $package"
    $installer $package
  fi
done

mkdir -p $PROJECTS_DIR
if [ ! -d "$PROJECTS_DIR/dotfiles" ]; then
  echo "Cloning dotfiles"
  (cd $PROJECTS_DIR && git clone -q $DOTFILES_REMOTE)
else
  echo "Updating dotfiles"
  (cd $PROJECTS_DIR/dotfiles && git pull -q)
fi
