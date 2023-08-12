#!/usr/bin/env bash

cd /root/dexyarch
source ./settings
source ./Pkgs
echo "--------------------------------------"
echo "--          Network Setup           --"
echo "--------------------------------------"
pacman -S networkmanager dhclient --noconfirm --needed
systemctl enable --now NetworkManager
echo "-------------------------------------------------"
echo "Setting up mirrors for optimal download          "
echo "-------------------------------------------------"
pacman -S --noconfirm pacman-contrib curl
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

nc=$(grep -c ^processor /proc/cpuinfo)
echo "You have " $nc" cores."
echo "-------------------------------------------------"
echo "Changing the makeflags for "$nc" cores."
TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTALMEM -gt 8000000 ]]; then
sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$nc\"/g" /etc/makepkg.conf
echo "Changing the compression settings for "$nc" cores."
sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g" /etc/makepkg.conf
fi
echo "-------------------------------------------------"
echo "       Setup Language to NO and set locale       "
echo "-------------------------------------------------"
ln -sf /usr/share/zoneinfo/Europe/Oslo /etc/localtime
loadkeys no-latin1
hwclock --systohc
cp -r /dots/etc/* /etc/
locale-gen

pacman -Syu --noconfirm

echo -e "\nInstalling Base System\n"

sudo pacman -S ${BASEPKGS[@]} --noconfirm --needed

if (( $GUI )); then
	echo "INSTALLING GRAPHICAL ENVIRONMENT"
	sudo pacman -S ${GUIPKGS[@]} --noconfirm --needed

	# Graphics Drivers find and install
	if lspci | grep -E "NVIDIA|GeForce"; then
	    pacman -S nvidia --noconfirm --needed
	elif lspci | grep -E "Radeon"; then
	    pacman -S xf86-video-amdgpu --noconfirm --needed
	elif lspci | grep -E "Integrated Graphics Controller"; then
	    pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
	fi
fi

#
# determine processor type and install microcode
#
proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
case "$proc_type" in
	GenuineIntel)
		print "Installing Intel microcode"
		pacman -S --noconfirm intel-ucode
		proc_ucode=intel-ucode.img
		;;
	AuthenticAMD)
		print "Installing AMD microcode"
		pacman -S --noconfirm amd-ucode
		proc_ucode=amd-ucode.img
		;;
esac

#add the user
useradd -m -G wheel,adm,rfkill,uucp -s /bin/bash $USER
echo -e $UPASS"\n"$UPASS | passwd $USER
echo -e $RPASS"\n"$RPASS | passwd
mkdir -p /home/$USER/build/
cp -R /root/dexyarch /home/$USER/build/
chown -R $USER: /home/$USER/build
echo $HNAME > /etc/hostname
echo "127.0.0.1 "$HNAME >> /etc/hosts

if (( $SSHD )); then
	systemctl enable sshd
fi
