
source settings
pacman -S --noconfirm archlinux-keyring 
pacman -S --noconfirm --needed networkmanager dhclient
systemctl enable --now NetworkManager
pacman -S - < Pkgs
# Enables Login display manager
sudo systemctl enable --now sddm.service
# sets dhcp and enables it:
# set keyboard layout:
loadkeys no-latin1
# sets ntp:
timedatectl set-ntp true
# Sets timezone
sleep 5
echo "Timezone Set to Europe/Oslo"
timedatectl --no-ask-password set-timezone Europe/Oslo

mkdir -p ../pictures/Screenshots/
mv .config ../
echo "Configs Moved"
WLR_NO_HARDWARE_CURSORS=1
echo "enabled cursors"

VMWARE=0
if [[ $(lspci | grep -c VMware) ]]; then
	read -p "VMware detected, would you like to install VMware-tools? [Y/n]:" Ans
	case $Ans in
		y|Y|yes|Yes|YES|"") VMWARE=1 ;;
		*) VMWARE=0 ;;
	esac
fi
echo "VMWARE="$VMWARE >> settings
if (( $VMWARE )); then
	sudo pacman -S --noconfirm open-vm-tools gtkmm gtk2
	sudo systemctl enable vmtoolsd
fi


echo "configuration done please reboot and login"