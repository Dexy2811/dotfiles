#!/bin/bash

# Abort if run as root
if [[ "$EUID" -eq 0 ]]; then
    echo "❌ Do NOT run this script as root!"
    echo "Run it as your normal user: ./backup.sh"
    exit 1
fi

# Set output directory
OUTPUT_DIR=~/Downloads
mkdir -p "$OUTPUT_DIR"

# Export installed packages
echo "Exporting list of explicitly installed packages..."
pacman -Qqe > "$OUTPUT_DIR/pkglist.txt"

echo "Exporting list of AUR packages..."
pacman -Qqm > "$OUTPUT_DIR/aurlist.txt"

# Backup selected configs
echo "Backing up config and dotfiles..."
tar -czvf "$OUTPUT_DIR/config-backup.tar.gz" \
    ~/.bashrc \
    ~/.bash_profile \
    ~/.gitconfig \
    ~/.config/alacritty \
    ~/.config/kitty \
    ~/.config/hypr \
    ~/.config/waybar \
    ~/.config/dunst \
    ~/.config/wofi \
    ~/.config/neofetch \
    ~/dotfiles \
    > /dev/null

echo "✅ Backup complete. Files saved in $OUTPUT_DIR"
