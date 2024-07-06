#!/usr/bin/env bash

set -e

if [ -z "$1" ]
  then
    sudo nix-collect-garbage  -d
  else
    sudo nix-collect-garbage  --delete-older-than $1
fi


# As a separation of concerns - you will need to run this command to clean out boot
sudo /run/current-system/bin/switch-to-configuration boot

# print free disk
df / -h