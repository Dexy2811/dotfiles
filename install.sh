pacman -S --noconfirm archlinux-keyring 
pacman -S - < pkglist.txt

# sets dhcp and enables it:
pacman -S --noconfirm --needed networkmanager dhclient
systemctl enable --now NetworkManager
# set keyboard layout:
loadkeys no-latin1

# sets ntp:
timedatectl set-ntp true
# Sets timezone
timedatectl --no-ask-password set-timezone Europe/Oslo

# Enables Login display manager (SDDM)
sudo systemctl enable --now sddm.service

mkdir -p ~/Pictures/Screenshots
cp .config $home/

Echo "Config copied and services enabled"