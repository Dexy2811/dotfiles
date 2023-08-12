#!/usr/bin/env bash

cd /root/dexyarch

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
