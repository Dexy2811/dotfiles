pacman -S - < pkglist.txt
pacman -S --noconfirm archlinux-keyring 
# sets dhcp and enables it:
pacman -S --noconfirm --needed networkmanager dhclient
systemctl enable --now NetworkManager
# set keyboard layout:
loadkeys no-latin1
# sets ntp:
timedatectl set-ntp true
# Sets timezone
timedatectl --no-ask-password set-timezone Europe/Oslo

# Enables Login display manager
sudo systemctl enable --now sddm.service

export $(XDG_SESSION_TYPE=wayland < .env)
export $(XDG_SESSION_DESKTOP=Hyprland < .env)
export $(XDG_CURRENT_DESKTOP=Hyprland < .env)

mkdir -p ~/Pictures/Screenshots
cp -r .config $home/

su dexy
Hyprland