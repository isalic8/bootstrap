all: _Packages _PackagesPython _PackagesNpm _PackagesFlatpak _Setup _SourcePackages _Adblock _Mimetypes

_Packages:
	ARCH=$(arch)
	sudo apt install aptitude -y
	if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
		sudo dpkg --add-architecture arm64
		sudo aptitude install -y $(sed '/#.*/d' ./assets/packages-arm64-deb | tr "\n" " ")
	else
		sudo dpkg --add-architecture i386 && sudo aptitude update
		sudo aptitude install -y $(sed '/#.*/d' ./assets/packages-deb | tr "\n" " ")
	fi
	sudo aptitude remove youtube-dl -y
	# Language server for coc-vim latex
	digestif

_PackagesPython:
	pip3 install --user $(cat ./assets/packages-python3)
	pip install --user $(cat ./assets/packages-python)

_PackagesNpm:
	npm install -g $(cat ./assets/packages-npm)
	#npm cache clean --force

_PackagesFlatpak:
	sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	#sudo flatpak install $(cat ./assets/packages-flatpak)

_Setup:
	sudo chown -R anon:anon /opt/
	cd /opt
	git clone https://github.com/isalic8/dwm.git
	git clone https://github.com/isalic8/dmenu.git
	git clone https://github.com/isalic8/dwmblocks.git
	git clone https://github.com/isalic8/st.git
	git clone https://github.com/isalic8/dotfiles.git ~/.dotfiles
	git clone https://github.com/isalic8/installers.git
	git clone https://github.com/isalic8/env.git
	# Dotfiles
	cd ~/.dotfiles
	rm ~/.bashrc ~/.profile
	stow *
	sudo install -m 755 "~/.w3m/cgi-bin-root/goto_clipboard.cgi" "/usr/lib/w3m/cgi-bin/goto_clipboard.cgi"
	sudo install -m 755 "~/.w3m/cgi-bin-root/restore_tab.cgi" "/usr/lib/w3m/cgi-bin/restore_tab.cgi"
	# Dwm
	cd /opt/dwm
	make clean
	make 
	sudo make install
	# St
	cd /opt/st
	make clean
	make 
	sudo make install
	#Dmenu
	cd /opt/dmenu
	make clean
	make 
	sudo make install

_Doas:
	install -o root -g root assets/doas.conf /etc/doas.conf

_SourcePackages:
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
	#./undercover
	./lemonbar
	./sc-im
	./mutt-wizard
	./v4l2loopback
	./bible
	./bsp-layout

_Adblock:
	sudo wget https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts -O /etc/hosts
	sudo sed -i "s/127.0.0.1 localhost/127.0.0.1 localhost $(hostname)/g" /etc/hosts
	sudo sed -i "s/127.0.0.1 localhost.localdomain/127.0.0.1 localhost.localdomain $(hostname)/g" /etc/hosts
	sudo sed -i "s/127.0.0.1 local/127.0.0.1 local $(hostname)/g" /etc/hosts
	sudo sed -i "s/255.255.255.255 broadcasthost/255.255.255.255 broadcasthost $(hostname)/g" /etc/hosts
	sudo sed -i "s/::1 localhost/::1 localhost $(hostname)/g" /etc/hosts
	sudo sed -i "s/::1 ip6-localhost/::1 ip6-localhost $(hostname)/g" /etc/hosts
	sudo sed -i "s/::1 ip6-loopback/::1 ip6-loopback $(hostname)/g" /etc/hosts
	sudo sed -i "s/fe80::1%lo0 localhost/fe80::1%lo0 localhost $(hostname)/g" /etc/hosts
	sudo sed -i "s/ff00::0 ip6-localnet/ff00::0 ip6-localnet $(hostname)/g" /etc/hosts
	sudo sed -i "s/ff00::0 ip6-mcastprefix/ff00::0 ip6-mcastprefix $(hostname)/g" /etc/hosts
	sudo sed -i "s/ff02::1 ip6-allnodes/ff02::1 ip6-allnodes $(hostname)/g" /etc/hosts
	sudo sed -i "s/ff02::2 ip6-allrouters/ff02::2 ip6-allrouters $(hostname)/g" /etc/hosts
	sudo sed -i "s/ff02::3 ip6-allhosts/ff02::3 ip6-allhosts $(hostname)/g" /etc/hosts

_Mimetypes:
	xdg-mime default feh.desktop image/png image/jpeg image/jpg
	xdg-mime default mpv.desktop image/gif

_DisableServices:
	sudo systemctl disable apache2
	sudo systemctl disable lightdm
	sudo systemctl disable smbd
	sudo systemctl disable exim4
	sudo systemctl disable samba-ad-dc
	sudo systemctl disable slim
	sudo systemctl disable transmission-daemon
	sudo systemctl disable mpd
	sudo systemctl disable ssh

_MiscSetup:
	# Download tldr database
	tldr -u
	# Update locate database
	sudo updatedb
	# Uncomplicated firewall
	sudo ufw enable
	# Tor with obfs4 bridges
#	sudo echo "UseBridges 1" >> /etc/tor/torrc
#	sudo echo "ClientTransportPlugin obfs2,obfs3,obfs4,scramblesuit exec /usr/bin/obfs4proxy" >> /etc/tor/torrc
#	sudo echo "Bridge obfs4 38.229.33.140:57275 EC4F9DA66F520A094E5B534AA08DFC1AB5E95B64 cert=OJJtSTddonrjXMCWGX97lIagsGtGiFnUI6t/OGFbKtpvWiFEfS0sLBnhLmHUENLoW1soeg iat-mode=1" >> /etc/tor/torrc
	# Set battery charge threshold on thinkpad
#	sudo sed -i 's/#START_CHARGE_THRESH_BAT0=75/START_CHARGE_THRESH_BAT0=75/g' /etc/default/tlp
#	sudo sed -i 's/#STOP_CHARGE_THRESH_BAT0=80/STOP_CHARGE_THRESH_BAT0=80/g' /etc/default/tlp
	#sudo rc-service tlp restart
#	sudo systemctl restart tlp 
	# Swappiness level to reduce disk writes
	sudo sysctl vm.swappiness=5
	sudo usermod -aG lp,lpadmin,floppy,dialout,audio,video,cdrom,plugdev,netdev $USER
	# Disables beep sound on xterm
#	sudo echo "blacklist pcspkr" >> /etc/modprobe.d/blacklist.conf
