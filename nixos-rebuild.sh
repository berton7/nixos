#!/usr/bin/env bash
# A rebuild script that commits on a successful build
set -e

if [ -z "${NIXOS_CONFIG_ROOT}" ]; then
	echo "Please set the environment variable \`dotfilesRoot\`"
	exit 1
fi

#Get configuration name, default to hostname
conf=${1:-$(hostname)}

# Autoformat your nix files
alejandra $NIXOS_CONFIG_ROOT >/dev/null

# Shows your changes
git -C $NIXOS_CONFIG_ROOT diff -U0

## Rebuild
sudo nixos-rebuild switch --flake $NIXOS_CONFIG_ROOT#$conf

# Get current generation metadata
current=$(nixos-rebuild list-generations --flake $NIXOS_CONFIG_ROOT#$conf | grep current)

# Commit all changes witih the generation metadata
git -C $NIXOS_CONFIG_ROOT commit -am "[$conf] $current"
