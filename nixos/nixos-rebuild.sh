#!/usr/bin/env bash
# A rebuild script that commits on a successful build
set -e

#Get configuration name, default to hostname
conf=${1:-$(hostname)}

# cd to your config dir
pushd ~/dotfiles/nixos/

# Autoformat your nix files
alejandra . >/dev/null

# Shows your changes
git diff -U0

## Rebuild
sudo nixos-rebuild switch --flake ~/dotfiles/nixos#$1

# Get current generation metadata
current=$(nixos-rebuild list-generations --flake ~/dotfiles/nixos#$conf | grep current)

# Commit all changes witih the generation metadata
git commit -am "$conf $current"

# Back to where you were
popd
