#!/bin/bash
echo "#!/bin/bash" > settings
pacman -Sy
pacman -S --noconfirm pacman-contrib terminus-font archlinux-keyring
setfont ter-v22b


echo "-------------------------------------------------"
echo "-------select the install disk-------------------"
echo "-------------------------------------------------"
echo "THIS WILL FORMAT AND DELETE ALL DATA ON THE DISK"
lsblk
echo "Please enter disk to work on: (example /dev/sda)"
read DISK
echo "DISK="$DISK >> settings
echo ""
read -p "Do you want a Graphical Environment [Y/n]:" GraphicAns
case $GraphicAns in
	y|Y|yes|Yes|YES|"") GUI=1 ;;
	*) GUI=0 ;;
esac
echo "GUI="$GUI >> settings
read -p "Enter hostname:" HNAME
echo "HNAME="$HNAME >> settings
read -p "Enter username:" USER
echo "USER="$USER >> settings
read -p "Enter userpass:" UPASS
echo "UPASS="$UPASS >> settings
read -p "Enter root pass:" RPASS
echo "RPASS="$RPASS >> settings

echo "Users created"

read -p "Enable SSH server? [Y/n]:" Ans
case $Ans in
	y|Y|yes|Yes|YES|"") SSHD=1 ;;
	*) SSHD=0 ;;
esac
echo "SSHD="$SSHD >> settings

echo "Detecting UEFI/BIOS"
if [[ -d "/sys/firmware/efi" ]]; then
	echo "EFI detected"
else
	echo "BIOS detected"
fi
echo "select $BOOTLOAD"
read -p "Select EFI or BIOS install [0 - BIOS, 1 - UEFI]:" BOOTLOAD
echo "BOOTLOAD="$BOOTLOAD >> settings

VMWARE=0
if [[ $(lspci | grep -c VMware) ]]; then
	read -p "VMware detected, would you like to install VMware-tools? [Y/n]:" Ans
	case $Ans in
		y|Y|yes|Yes|YES|"") VMWARE=1 ;;
		*) VMWARE=0 ;;
	esac
fi
echo "VMWARE="$VMWARE >> settings
