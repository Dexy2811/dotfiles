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
echo export $(run-parts /usr/lib/systemd/user-environment-generators | sed '/:$/d; /^$/d' | xargs) > ../.bash_profile
mkdir -p ../pictures/Screenshots/
mv .config ../
echo "Configs Moved"

mv hypr.desktop /usr/share/wayland-sessions/hypr.desktop
echo ".desktop file moved"

mv Hypr.sh > /usr/local/bin/
echo "Hpyr config moved"

sudo -u dexy -H sh -c "Hyprland"