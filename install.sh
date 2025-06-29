#!/bin/bash

# Prevent full script from being run with sudo
if [[ "$EUID" -eq 0 ]]; then
    echo "❌ Do NOT run this script with sudo."
    echo "Run it normally: ./install.sh [--force]"
    exit 1
fi

# Config
USERNAME=dexy
INPUT_DIR="/home/$USERNAME/Downloads"
DOTFILES_REPO="https://github.com/Dexy2811/dotfiles"
SDDM_THEME_REPO="https://github.com/Dexy2811/sddm-astronaut-theme"

# Check for --force flag
FORCE=false
if [[ "$1" == "--force" ]]; then
    FORCE=true
fi

# Create user if not exists
if ! id "$USERNAME" &>/dev/null; then
    echo "Creating user $USERNAME..."
    sudo useradd -m -G wheel -s /bin/bash "$USERNAME"
    echo "Set password for $USERNAME:"
    sudo passwd "$USERNAME"
    echo "%wheel ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers
fi

# Install git and base-devel
echo "Installing base-devel and git..."
sudo pacman -Sy --noconfirm base-devel git

# Run user setup script as $USERNAME
sudo -u "$USERNAME" bash <<EOF
FORCE=$FORCE
DOTFILES_REPO=$DOTFILES_REPO

# Clone dotfiles
if [[ ! -d ~/dotfiles ]]; then
    echo "Cloning dotfiles..."
    git clone \$DOTFILES_REPO ~/dotfiles
else
    echo "Dotfiles already exist, skipping clone."
fi

# Create Downloads dir
mkdir -p ~/Downloads

# Copy wallpapers from dotfiles to Pictures
if [[ -d ~/dotfiles/Wallpapers ]]; then
    mkdir -p ~/Pictures/Wallpapers
    cp -r ~/dotfiles/Wallpapers/* ~/Pictures/Wallpapers/
    echo "✅ Wallpapers copied to ~/Pictures/Wallpapers"
fi

# Install yay
if ! command -v yay &>/dev/null; then
    echo "Installing yay..."
    cd ~
    git clone https://aur.archlinux.org/yay.git
    cd yay && makepkg -si --noconfirm
    cd .. && rm -rf yay
else
    echo "yay already installed, skipping."
fi

# Restore configs
if [[ -f ~/Downloads/config-backup.tar.gz ]]; then
    if [[ "\$FORCE" == "true" ]]; then
        echo "Forcing config restore..."
        tar -xzvf ~/Downloads/config-backup.tar.gz -C ~/
    elif [[ -d ~/.config ]]; then
        read -p "~/.config exists. Overwrite? (y/n): " answer
        if [[ "\$answer" =~ ^[Yy]$ ]]; then
            echo "Overwriting ~/.config..."
            rm -rf ~/.config
            tar -xzvf ~/Downloads/config-backup.tar.gz -C ~/
        else
            echo "Skipping config restore."
        fi
    else
        echo "Restoring config..."
        tar -xzvf ~/Downloads/config-backup.tar.gz -C ~/
    fi
else
    echo "No config-backup.tar.gz found."
fi

# Install official packages
if [[ -f ~/Downloads/pkglist.txt ]]; then
    echo "Installing official packages..."
    xargs -a ~/Downloads/pkglist.txt -r -- sudo pacman -S --needed --noconfirm || true
else
    echo "No pkglist.txt found."
fi

# Install AUR packages (skip youtube-music-bin if manual)
if [[ -f ~/Downloads/aurlist.txt ]]; then
    echo "Installing AUR packages..."
    grep -v '^youtube-music-bin$' ~/Downloads/aurlist.txt | yay -S --needed --noconfirm || true

    if ! command -v youtube-music &>/dev/null; then
        echo "Manually installing youtube-music-bin..."
        cd ~/Downloads
        git clone https://aur.archlinux.org/youtube-music-bin.git
        cd youtube-music-bin
        makepkg -si --noconfirm
        cd ..
        rm -rf youtube-music-bin
    else
        echo "youtube-music already installed, skipping manual build."
    fi
else
    echo "No aurlist.txt found."
fi
EOF

# Set wallpaper path from Pictures folder
wallpaper_file=$(find /home/$USERNAME/Pictures/Wallpapers -type f -iregex '.*\.\(jpg\|png\|jpeg\)' | head -n1)
if [[ -n "$wallpaper_file" && -f /etc/sddm.conf ]]; then
    old_path=$(grep Background /etc/sddm.conf | cut -d '=' -f2 | xargs)
    sudo sed -i "s|$old_path|$wallpaper_file|g" /etc/sddm.conf
    echo "🎨 SDDM wallpaper updated to: $wallpaper_file"
fi

echo "🔧 Enabling essential system services..."

# Enable SDDM
sudo systemctl enable sddm

# Set Hyprland as default session
if [[ ! -f "/home/$USERNAME/.xinitrc" ]]; then
    echo "exec Hyprland" | sudo tee /home/$USERNAME/.xinitrc > /dev/null
    sudo chown $USERNAME:$USERNAME /home/$USERNAME/.xinitrc
fi

# Install SDDM theme from GitHub
echo "Installing sddm-astronaut-theme..."
sudo git clone "$SDDM_THEME_REPO" /usr/share/sddm/themes/sddm-astronaut-theme
sudo chown -R root:root /usr/share/sddm/themes/sddm-astronaut-theme

# Set SDDM theme
if grep -q "Current=" /etc/sddm.conf; then
    sudo sed -i "s|^Current=.*|Current=sddm-astronaut-theme|" /etc/sddm.conf
else
    echo "[Theme]" | sudo tee -a /etc/sddm.conf
    echo "Current=sddm-astronaut-theme" | sudo tee -a /etc/sddm.conf
fi

# Enable networking
if systemctl list-unit-files | grep -q NetworkManager.service; then
    sudo systemctl enable NetworkManager
elif systemctl list-unit-files | grep -q systemd-networkd.service; then
    sudo systemctl enable systemd-networkd
    sudo systemctl enable systemd-resolved
fi

# ✅ Cleanup
echo "🧹 Cleaning up..."
sudo rm -rf /home/$USERNAME/Downloads/yay
sudo rm -rf /home/$USERNAME/Downloads/youtube-music-bin
sudo rm -f /home/$USERNAME/Downloads/pkglist.txt
sudo rm -f /home/$USERNAME/Downloads/aurlist.txt
sudo rm -f /home/$USERNAME/Downloads/config-backup.tar.gz
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME
sudo rm -f /home/$USERNAME/.bash_history

echo "✅ All done. Ready to boot into your full Hyprland setup!"
