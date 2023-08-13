#!/bin/bash
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

echo "-------------------------------------------------"
echo "Setting up mirrors for optimal download          "
echo "-------------------------------------------------"

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ./settings
timedatectl set-ntp true
sed -i 's/^#Para/Para/' /etc/pacman.conf
pacman -S --noconfirm curl rsync grub unzip

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
echo -e "-------------------------------------------------------------------------"
echo -e "-Setting up Norway mirrors for faster downloads"
echo -e "-------------------------------------------------------------------------"

#download new mirrorlist and sort by fastest
if [[ ! -f /etc/pacman.d/mirrorlist.new ]]; then #ranking takes a second, will only already exist if we are running multiple times (during debugging)
	cd /etc/pacman.d/
	curl "https://archlinux.org/mirrorlist/?country=CA&country=US&protocol=http&protocol=https&ip_version=4&use_mirror_status=on" -o "mirrorlist.new"
	sed -i 's/^#Server/Server/' 'mirrorlist.new'
	echo "Ranking Mirrors"
	rankmirrors -n 10 mirrorlist.new > mirrorlist
	echo "Mirrors Ranked"
else
	echo "Mirrors already ranked"
fi
cd /


mkdir /mnt/root
mkdir /mnt/root/dexyarch

echo -e "\nInstalling prereqs...\n$HR"
pacman -S --noconfirm gptfdisk

echo "--------------------------------------"
echo -e "\nFormatting disk...\n$HR"
echo "--------------------------------------"
lsblk
echo "Enter the drive to install arch linux on it. (/dev/...)"
echo "Enter Drive (eg. /dev/sda or /dev/vda or /dev/nvme0n1 or something similar)"
read drive
sleep 2s
clear


lsblk
echo "Choose a familier disk utility tool to partition your drive!"
echo " 1. fdisk"
echo " 2. cfdisk"
echo " 3. gdisk"
echo " 4. parted"
read partitionutility

case "$partitionutility" in
  1 | fdisk | Fdisk | FDISK)
  partitionutility="fdisk"
  ;;
  2 | cfdisk | Cfdisk | CFDISK)
  partitionutility="cfdisk"
  ;;
  3 | gdisk | Gdisk | GDISK)
  partitionutility="gdisk"
  ;;
  4 | parted | Parted | PARTED)
  partitionutility="parted"
  ;;
  *)
  echo "Unknown or unsupported disk utility! Default = cfdisk."
  partitionutility="cfdisk"
  ;;
esac
echo ""$partitionutility" is the selected disk utility tool for partition."
sleep 3s
clear
echo "Getting ready for creating partitions!"
echo "root and boot partitions are mandatory."
echo "home and swap partitions are optional but recommended!"
echo "Also, you can create a separate partition for timeshift backup (optional)!"
echo "Getting ready in 9 seconds"
sleep 9s
"$partitionutility" "$drive"
clear
lsblk
echo "choose your linux file system type for formatting drives"
echo " 1. ext4"
echo " 2. xfs"
echo " 3. btrfs"
echo " 4. f2fs"
echo " Boot partition will be formatted in fat32 file system type."
read filesystemtype

case "$filesystemtype" in
  1 | ext4 | Ext4 | EXT4)
  filesystemtype="ext4"
  ;;
  2 | xfs | Xfs | XFS)
  filesystemtype="xfs"
  ;;
  3 | btrfs | Btrfs | BTRFS)
  filesystemtype="btrfs"
  ;;
  4 | f2fs | F2fs | F2FS)
  filesystemtype="f2fs"
  ;;
  *)
  echo "Unknown or unsupported Filesystem. Default = ext4."
  filesystemtype="ext4"
  ;;
esac
echo ""$filesystemtype" is the selected file system type."

if ! grep -qs '/mnt' /proc/mounts; then
    echo "Drive is not mounted can not continue"
    echo "Rebooting in 3 Seconds ..." && sleep 1
    echo "Rebooting in 2 Seconds ..." && sleep 1
    echo "Rebooting in 1 Second ..." && sleep 1
    reboot now
fi

read -p "ready to install. continue?" con

echo "--------------------------------------"
echo "-- Arch Install on Main Drive       --"
echo "--------------------------------------"
pacstrap /mnt base base-devel linux linux-firmware linux-headers git libnewt unzip --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab
cp install.sh /mnt/root/dexyarch
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

echo "--------------------------------------"
echo "--GRUB BIOS Bootloader Install&Check--"
echo "--------------------------------------"
if [[ ! -d "/sys/firmware/efi" ]]; then
    grub-install --boot-directory=/mnt/boot ${DISK}
fi
echo "--------------------------------------"
echo "--   SYSTEM READY FOR 1-setup       --"
echo "--------------------------------------"
#read -p "continue?" con


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


cd ~/build/dexyarch
source ./settings
source ./Pkgs
cd ~
mkdir ~/.local
xdg-user-dirs-update


echo "Loading the pacUpdt timer"
cd ~/build/
git clone https://github.com/Michae11s/pacUpdt.git
cd pacUpdt/
makepkg -si --noconfirm
sudo systemctl enable pacUpdt.timer

if (( $GUI )); then
	echo "Import spotify gpg key"
	curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | gpg --import -
	for PKG in "${AURPKGS[@]}"; do
		cd ~/build
		echo "****************************************************"
		echo "*** Installing: "$PKG" ***"
		echo "****************************************************"
		auracle clone $PKG
		cd $PKG
		makepkg -si --noconfirm
	done

	#run inital flavours commands
	flavours update all
fi

if (( $VMWARE )); then
	sudo pacman -S --noconfirm open-vm-tools gtkmm gtk2
	sudo systemctl enable vmtoolsd
fi

echo -e "\nDone 2-user\n"

cd /root/dexyarch
source ./settings
echo -e "\nFINAL SETUP AND CONFIGURATION"
echo "--------------------------------------"
echo "-- GRUB EFI Bootloader Install&Check--"
echo "--------------------------------------"
if (( $BOOTLOAD )); then
	grub-install --target x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
else
	grub-install --target=i386-pc $DISK
fi
grub-mkconfig -o /boot/grub/grub.cfg

# ------------------------------------------------------------------------

if (( $GUI )); then
	echo -e "\nEnabling Login Display Manager"
	systemctl enable sddm.service
	echo -e "\nSetup SDDM Theme"
	#cat <<EOF > /etc/sddm.conf
	#[Theme]
	#Current=Nordic
	#EOF
fi
# ------------------------------------------------------------------------

echo -e "\nEnabling essential services"

systemctl enable cups.service
systemctl enable NetworkManager.service
systemctl enable bluetooth
echo "
###############################################################################
# Cleaning
###############################################################################
"

read -p "Install finished. Reboot? [Y/n]:" Ans
case $Ans in
   y|Y|yes|Yes|YES|"") reboot ;;
esac
