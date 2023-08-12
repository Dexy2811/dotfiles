#!/usr/bin/env bash

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
echo -e "-Setting up US & Canada mirrors for faster downloads"
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

mkdir -p /mnt


echo -e "\nInstalling prereqs...\n$HR"
pacman -S --noconfirm gptfdisk

echo "--------------------------------------"
echo -e "\nFormatting disk...\n$HR"
echo "--------------------------------------"
#read -p "continue?" con
# disk prep
sgdisk -Z ${DISK} # zap all on disk
sgdisk -a 2048 -o ${DISK} # new gpt disk 2048 alignment

# create partitions
sgdisk -n 1::+1M --typecode=1:ef02 --change-name=1:'BIOSBOOT' ${DISK} # partition 1 (BIOS Boot Partition)
sgdisk -n 2::+500M --typecode=2:ef00 --change-name=2:'EFIBOOT' ${DISK} # partition 2 (UEFI Boot Partition)
sgdisk -n 3::+10G --typecode=3:8300 --change-name=3:'ROOT' ${DISK} # partition 3 (Root), default start, minus 10G for swap
if [[ ! -d "/sys/firmware/efi" ]]; then
    sgdisk -A 1:set:2 ${DISK}
fi

#read -p "continue?" con

# make filesystems
echo -e "\nCreating Filesystems...\n$HR"
if [[ ${DISK} =~ "nvme" ]]; then
mkfs.vfat -F32 -n "EFIBOOT" "${DISK}p2"
mkfs.btrfs -L "ROOT" "${DISK}p3" -F
mount "${DISK}p3" /mnt
mkswap "${DISK}p4"
swapon "${DISK}p4"
else
mkfs.vfat -F32 -n "EFIBOOT" "${DISK}2"
mkfs.btrfs -L "ROOT" "${DISK}3" -F
mount "${DISK}3" /mnt
fi

mkdir /mnt/boot
mount -t vfat -L EFIBOOT /mnt/boot/
mkdir /mnt/boot/efi

if ! grep -qs '/mnt' /proc/mounts; then
    echo "Drive is not mounted can not continue"
    echo "Rebooting in 3 Seconds ..." && sleep 1
    echo "Rebooting in 2 Seconds ..." && sleep 1
    echo "Rebooting in 1 Second ..." && sleep 1
    reboot now
fi

#read -p "ready to install. continue?" con

echo "--------------------------------------"
echo "-- Arch Install on Main Drive       --"
echo "--------------------------------------"
pacstrap /mnt base base-devel linux linux-firmware linux-headers git libnewt unzip --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab
cp -R ${SCRIPT_DIR} /mnt/root/dexyarch
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
