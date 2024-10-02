#!/usr/bin/env bash
# A rebuild script that commits on a successful build
set -e

if [ -z "${dotfilesRoot}" ]; then
	echo "Please set the environment variable \`dotfilesRoot\`"
	exit 1
fi

#Get configuration name, default to hostname
conf=${1:-$(hostname)}

# Autoformat your nix files
alejandra $dotfilesRoot >/dev/null

# Shows your changes
git -C $dotfilesRoot diff -U0

## Rebuild
sudo nixos-rebuild switch --flake $dotfilesRoot#$conf

# Get current generation metadata
current=$(nixos-rebuild list-generations --flake $dotfilesRoot#$conf | grep current)

# Commit all changes witih the generation metadata
git -C $dotfilesRoot commit -am "$conf $current"
