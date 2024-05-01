#!/usr/bin/env bash
# A rebuild script that commits on a successful build
set -e

if [ -z "$1" ]
  then
    echo "Configuration name not present. Example usage: \`nixos-rebuild.sh default\`"
    exit 1
fi

# cd to your config dir
pushd ~/dotfiles/nixos/

# Autoformat your nix files
alejandra . >/dev/null

# Shows your changes
git diff -U0

## Rebuild
sudo nixos-rebuild switch --flake ~/dotfiles/nixos#$1

# Get current generation metadata
current=$(nixos-rebuild list-generations --flake ~/dotfiles/nixos#$1 | grep current)

# Commit all changes witih the generation metadata
git commit -am "$1 $current"

# Back to where you were
popd
