#!/bin/sh

clone(){
	cd /opt
	git clone gitunix:/srv/git/dwm.git
	git clone gitunix:/srv/git/slstatus.git
	git clone gitunix:/srv/git/st.git
	git clone gitunix:/srv/git/dotfiles.git ~/.dotfiles
	git clone gitunix:/srv/git/dox.git
	git clone gitunix:/srv/git/installers.git
	git clone gitunix:/srv/git/ebooks.git
}

suckless-install(){
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

software-install(){
	sudo aptitude install -y $(grep -vE "^\s*#" /opt/bootstrap/packages-deb | tr "\n" " ")
}

misc-install(){
	cd /opt/installers
	./nyancat
	./tty-clock
	./tmux
	./arch-wiki
	./adobe-source-code-pro
	./sent
}

disable-services(){
	init = openrc
	if [ "$init" = "openrc" ]; then
		sudo rc-update del apache2
		sudo rc-update del lightdm
		sudo rc-update del smbd
		sudo rc-update del samba-ad-dc
		sudo rc-update del slim
	elif [ "$init" = "systemd" ]; then
		sudo systemctl disable apache2 
		sudo systemctl disable samba
		sudo systemctl disable lightdm 
		sudo systemctl disable slim 
	fi
}

misc-setup(){
	sudo updatedb
	sudo sed -i 's/socks4/socks5/g' /etc/proxychains.conf
	sudo sed -i 's/#quiet_mode/quiet_mode/g' /etc/proxychains.conf
	sudo /etc/init.d/transmission-daemon stop
	sudo sed -i 's;rpc-authentication-required: true;rpc-authentication-required: false;g' /etc/transmission-daemon/settings.json
}

clone
software-install
suckless-install
misc-install
misc-setup
disable-services
