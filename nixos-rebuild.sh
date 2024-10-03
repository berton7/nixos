#!/usr/bin/env bash
# A rebuild script that commits on a successful build
set -e

if [ -z "${DOTFILES_ROOT}" ]; then
	echo "Please set the environment variable \`dotfilesRoot\`"
	exit 1
fi

#Get configuration name, default to hostname
conf=${1:-$(hostname)}

# Autoformat your nix files
alejandra $DOTFILES_ROOT >/dev/null

# Shows your changes
git -C $DOTFILES_ROOT diff -U0

## Rebuild
sudo nixos-rebuild switch --flake $DOTFILES_ROOT#$conf

# Get current generation metadata
current=$(nixos-rebuild list-generations --flake $DOTFILES_ROOT#$conf | grep current)

# Commit all changes witih the generation metadata
git -C $DOTFILES_ROOT commit -am "$conf $current"
