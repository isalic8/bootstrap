#!/bin/sh

clone(){
	cd /opt
	git clone gitunix:/srv/git/dwm.git
	git clone gitunix:/srv/git/slstatus.git
	git clone gitunix:/srv/git/st.git
	git clone gitunix:/srv/git/dotfiles.git ~/.dotfiles
	git clone gitunix:/srv/git/dox.git
	git clone gitunix:/srv/git/installers.git
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
		sudo rc-service apache2 stop
		sudo rc-update del lightdm
		sudo rc-update del slim
	elif [ "$init" = "systemd" ]; then
		sudo systemctl disable apache2 
		sudo systemctl stop apache2 
		sudo systemctl disable lightdm 
		sudo systemctl disable slim 
	fi
}

misc-setup(){
}

clone
software-install
suckless-install
misc-install
disable-services
