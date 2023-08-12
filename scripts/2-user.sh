#!/usr/bin/env bash
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
exit
