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
echo export $(run-parts /usr/lib/systemd/user-environment-generators | sed '/:$/d; /^$/d' | xargs) > ~/.bash.profile
mkdir -p ~/Pictures/Screenshots
mv .config ../

su dexy
Hyprland