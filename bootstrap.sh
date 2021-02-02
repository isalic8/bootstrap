#!/bin/sh
ARCH=$(arch)
INIT=systemd
#INIT=openrc

clone(){
	cd /opt
	git clone github:/isalic8/dwm.git
	git clone github:/isalic8/dwmblocks.git
	git clone github:/isalic8/st.git
	git clone github:/isalic8/dotfiles.git ~/.dotfiles
	git clone github:/isalic8/dox.git ~/dox
	git clone github:/isalic8/installers.git
	git clone github:/isalic8/env.git
}

suckless_install(){
	cd /opt/dwm
	make clean
	make 
	sudo make install

	cd /opt/st
	make clean
	make 
	sudo make install
}

software_install(){
	#/bin/bash -c "$(curl -sL https://git.io/vokNn)"
	#sudo apt install aptitude aria2 -y
	if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
		#sudo apt-fast install -y $(grep -vE "^\s*#" /opt/bootstrap/packages-arm64-deb | tr "\n" " ")
		sudo apt install -y $(sed '/#.*/d' /opt/bootstrap/packages-arm64-deb | tr "\n" " ")
	else
		sudo dpkg--add-architecture i386 && sudo apt update
		#sudo apt-fast install -y $(grep -vE "^\s*#" /opt/bootstrap/packages-deb | tr "\n" " ")
		sudo apt install -y $(sed '/#.*/d' /opt/bootstrap/packages-deb | tr "\n" " ")
	fi

	sudo apt remove youtube-dl -y
	npm install -g bash-language-server instant-markdown-d
	pip3 install --user $(cat /opt/bootstrap/packages-python)
	# Language server for coc-vim latex
	digestif
}

misc_install(){
	cd /opt/installers
	./nyancat
	./tty-clock
	./tmux
	./arch-wiki
	./sent
	./adobe-source-code-pro
	./font-terminus
	./font-symbola
	./tor-browser
	./cmatrix
	./youtube-dl
	./xbanish
	./scrot
	./unshorten-url-js
	./undercover
	./sc-im
	./gomuks
	./mutt-wizard
	./v4l2loopback
}

disable_services(){
	case "$INIT" in
		openrc) 
			sudo rc-update del apache2
			sudo rc-update del lightdm
			sudo rc-update del smbd
			sudo rc-update del exim4
			sudo rc-update del samba-ad-dc
			sudo rc-update del slim
			sudo rc-update del transmission-daemon
			sudo rc-update del mpd
			sudo rc-update del ssh
			;;
		systemd)
			sudo systemctl disable apache2
			sudo systemctl disable lightdm
			sudo systemctl disable smbd
			sudo systemctl disable exim4
			sudo systemctl disable samba-ad-dc
			sudo systemctl disable slim
			sudo systemctl disable transmission-daemon
			sudo systemctl disable mpd
			sudo systemctl disable ssh
			;;
	esac
}

misc_setup(){
	# Download tldr database
	tldr -u
	# Update locate database
	sudo updatedb
	# Uncomplicated firewall
	sudo ufw enable
	# Flatpak repos
	sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	# Tor with obfs4 bridges
#	sudo echo "UseBridges 1" >> /etc/tor/torrc
#	sudo echo "ClientTransportPlugin obfs2,obfs3,obfs4,scramblesuit exec /usr/bin/obfs4proxy" >> /etc/tor/torrc
#	sudo echo "Bridge obfs4 38.229.33.140:57275 EC4F9DA66F520A094E5B534AA08DFC1AB5E95B64 cert=OJJtSTddonrjXMCWGX97lIagsGtGiFnUI6t/OGFbKtpvWiFEfS0sLBnhLmHUENLoW1soeg iat-mode=1" >> /etc/tor/torrc
	# Set battery charge threshold on thinkpad
#	sudo sed -i 's/#START_CHARGE_THRESH_BAT0=75/START_CHARGE_THRESH_BAT0=75/g' /etc/default/tlp
#	sudo sed -i 's/#STOP_CHARGE_THRESH_BAT0=80/STOP_CHARGE_THRESH_BAT0=80/g' /etc/default/tlp
	#sudo rc-service tlp restart
#	sudo systemctl restart tlp 
	# Swappiness level to avoid ssd wear
	sudo sysctl vm.swappiness=5
	sudo usermod -aG lp,lpadmin,floppy,dialout,audio,video,cdrom,plugdev,netdev $USER
	# Disables beep sound on xterm
#	sudo echo "blacklist pcspkr" >> /etc/modprobe.d/blacklist.conf
	# Change swappiness level to something flash friendly
	sudo sysctl vm.swappiness=5
	# Setting default applications
	xdg-mime default feh.desktop image/png image/jpeg image/jpg
	xdg-mime default mpv.desktop image/gif
}

clone
software_install
suckless_install
misc_install
misc_setup
disable_services
