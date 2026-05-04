#!/bin/bash

# Exit on error
set -e

echo "Starting dotfiles setup..."

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo "GNU Stow is not installed. Attempting to install it..."
    if command -v dnf &> /dev/null; then
        sudo dnf install -y stow
    elif command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y stow
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm stow
    elif command -v brew &> /dev/null; then
        brew install stow
    else
        echo "Could not find a supported package manager. Please install GNU Stow manually."
        exit 1
    fi
else
    echo "GNU Stow is already installed."
fi

# Navigate to the dotfiles directory
cd ~/dotfiles

# Run stow for the configurations

echo "Stowing zsh configs..."
stow zsh

echo "Stowing git configs..."
stow git

echo "Done! All configurations are successfully stowed."
