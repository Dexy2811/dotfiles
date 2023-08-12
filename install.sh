#!/bin/bash

mkdir -p ../pictures/Screenshots/
mv .config ../
echo "Configs Moved"

bash scripts/00-setupvars.sh
#read -p "00 Finished. Continue?" con
bash scripts/0-preinstall.sh
#read -p "0 Finished. Continue?" con
arch-chroot /mnt /root/dexyarch/1-setup.sh
#read -p "1 Finished. Continue?" con
arch-chroot /mnt /usr/bin/runuser -u $USER -- /home/$USER/build/dexyarch/2-user.sh
#read -p "2 Finished. Continue?" con
arch-chroot /mnt /root/dexyarch/3-post-setup.sh
rm -r /mnt/root/dexyarch/
read -p "Install finished. Reboot? [Y/n]:" Ans
case $Ans in
   y|Y|yes|Yes|YES|"") reboot ;;
esac
