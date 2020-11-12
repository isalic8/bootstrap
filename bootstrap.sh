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
	./python3.9
}

disable_services(){
	sudo rc-update del apache2
	sudo rc-update del lightdm
	sudo rc-update del smbd
	sudo rc-update del samba-ad-dc
	sudo rc-update del slim
}

misc_setup(){
	sudo updatedb
	sudo sed -i 's/socks4/socks5/g' /etc/proxychains.conf
	sudo sed -i 's/#quiet_mode/quiet_mode/g' /etc/proxychains.conf
	sudo /etc/init.d/transmission-daemon stop
	sudo sed -i 's;rpc-authentication-required: true;rpc-authentication-required: false;g' /etc/transmission-daemon/settings.json
}

clone
software_install
suckless_install
misc_install
misc_setup
disable_services
