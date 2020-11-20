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
}

disable_services(){
	sudo rc-update del apache2
	sudo rc-update del lightdm
	sudo rc-update del smbd
	sudo rc-update del exim4
	sudo rc-update del samba-ad-dc
	sudo rc-update del slim
	sudo rc-update del transmission-daemon
}

misc_setup(){
	# Update locate database
	sudo updatedb
	# Black list sound drivers to disable microphone
	sudo echo "blacklist snd_hda_intel" >> /etc/modprobe.d/blacklist.conf
	sudo echo "blacklist thinkpad_acpi" >> /etc/modprobe.d/blacklist.conf
	# Uncomplicated firewall
	sudo ufw enable
}

clone
software_install
suckless_install
misc_install
misc_setup
disable_services
