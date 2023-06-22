sudo pacman -S - < pkglist.txt
sudo pacman -S --noconfirm archlinux-keyring 
# sets dhcp and enables it:
sudo pacman -S --noconfirm --needed networkmanager dhclient
sudo systemctl enable --now NetworkManager
# set keyboard layout:
sudo loadkeys no-latin1
# sets ntp:
sudo timedatectl set-ntp true
# Sets timezone
sudo timedatectl --no-ask-password set-timezone Europe/Oslo

# Enables Login display manager
sudo systemctl enable --now sddm.service

cp .config $home/
Echo "Config copied and services enabled"

Hyprland