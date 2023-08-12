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
sleep 5
echo "Timezone Set to Europe/Oslo"
timedatectl --no-ask-password set-timezone Europe/Oslo

# Enables Login display manager
sudo systemctl enable --now sddm.service
mkdir -p ../pictures/Screenshots/
mv .config ../
echo "Configs Moved"
export WLR_NO_HARDWARE_CURSORS=1
echo "enabled cursors"
echo "configuration done please reboot and login"