#!/bin/sh

clone(){
	cd /opt
	git clone gitunix:/srv/git/dwm.git
	git clone gitunix:/srv/git/slstatus.git
	git clone gitunix:/srv/git/st.git
	git clone gitunix:/srv/git/dotfiles.git ~/.dotfiles
	git clone gitunix:/srv/git/dox.git ~/dox
	git clone gitunix:/srv/git/installers.git
	git clone gitunix:/srv/git/ebooks.git
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

	cd /opt/slstatus
	make clean
	make 
	sudo make install
}

software_install(){
	sudo dpkg--add-architecture i386 && sudo apt update
	sudo apt install aptitude -y
	sudo aptitude install -y $(grep -vE "^\s*#" /opt/bootstrap/packages-deb | tr "\n" " ")
	sudo apt remove mate-notification-daemon mate-notification-daemon-common -y
	sudo apt remove youtube-dl -y
}

misc_install(){
	cd /opt/installers
	./nyancat
	./tty-clock
	./tmux
	./lf-source
	./arch-wiki
	./sent
	./adobe-source-code-pro
	./font-terminus
	./tor-browser
	./cmatrix
	./youtube-dl
	./xbanish
}

disable_services(){
	sudo rc-update del apache2
	sudo rc-update del lightdm
	sudo rc-update del smbd
	sudo rc-update del exim4
	sudo rc-update del samba-ad-dc
	sudo rc-update del slim
	sudo rc-update del transmission-daemon
	sudo rc-update del mpd
}

misc_setup(){
	# Update locate database
	sudo updatedb
	# Black list sound drivers to disable microphone
	sudo echo "blacklist snd_hda_intel" >> /etc/modprobe.d/blacklist.conf
	sudo echo "blacklist thinkpad_acpi" >> /etc/modprobe.d/blacklist.conf
	# Uncomplicated firewall
	sudo ufw enable
	# Flatpak repos
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	# Tor with obfs4 bridges
	sudo echo "UseBridges 1" >> /etc/tor/torrc
	sudo echo "ClientTransportPlugin obfs2,obfs3,obfs4,scramblesuit exec /usr/bin/obfs4proxy" >> /etc/tor/torrc
	sudo echo "Bridge obfs4 38.229.33.140:57275 EC4F9DA66F520A094E5B534AA08DFC1AB5E95B64 cert=OJJtSTddonrjXMCWGX97lIagsGtGiFnUI6t/OGFbKtpvWiFEfS0sLBnhLmHUENLoW1soeg iat-mode=1" >> /etc/tor/torrc
	# Set battery charge threshold on thinkpad
	sudo sed -i 's/#START_CHARGE_THRESH_BAT0=75/START_CHARGE_THRESH_BAT0=75/g' /etc/default/tlp
	sudo sed -i 's/#STOP_CHARGE_THRESH_BAT0=80/STOP_CHARGE_THRESH_BAT0=80/g' /etc/default/tlp
	sudo rc-service tlp restart
	# Swappiness level to avoid ssd wear
	sudo sysctl vm.swappiness=5
	sudo usermod -a -G lp,floppy,dialout,audio,video,cdrom,plugdev,netdev,scanner $USER
	# Disables beep sound on xterm
	sudo echo "blacklist pcspkr" >> /etc/modprobe.d/blacklist.conf
	# Enable firejail for every application
	sudo firecfg
}

clone
software_install
suckless_install
misc_install
misc_setup
disable_services
