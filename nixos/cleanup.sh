#!/usr/bin/env bash

set -e

if [ -z "$1" ]
  then
    echo "Missing \"--delete-older-than\" value. Example usage: \`~/dotfiles/nixos/cleanup.sh 30d\`"
    exit 1
fi

sudo nix-collect-garbage  --delete-older-than $1

# As a separation of concerns - you will need to run this command to clean out boot
sudo /run/current-system/bin/switch-to-configuration boot