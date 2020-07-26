#!/bin/sh
# Pulls my software and dotfile. Requires Arch Linux.
# Run this on a fresh user account with an empty home directory.
# Stow doesn't overwrite files. If a directory/file already exists, it skips it.

# Use doas instead of sudo
if [ -x "$(command -v doas)" ]; then
	read -p "Use doas instead of sudo [y/n]? " yn
	case $yn in
		[yY][eE][sS]|[yY]) sudo=doas;;
		[nN][oO]|[nN]) continue;;
		*) printf "Invalid input\n";;
	esac
fi

# Install AUR helper if not present
if [ -x "$(command -v yay)" ]; then
	break
else
	read -p "Yay is not installed. Install it? [y/n]? " yn
	case $yn in
		[yY][eE][sS]|[yY]) 
			printf "Checking if makepkg is installed...\n"
			[ -x "$(command -v makepkg)" ] || $sudo pacman -S base-devel --noconfirm
			printf "Checking if git is installed...\n"
			[ -x "$(command -v git)" ] || $sudo pacman -S git --noconfirm
			git clone https://aur.archlinux.org/yay.git /tmp
			cd /tmp/yay
			makepkg
			;;
		[nN][oO]|[nN]) continue;;
		*) printf "Invalid input\n";;
	esac
fi

# Install dotfiles
function dots{
	if [ -x "$(command -v stow)" ]; then
		break
	else
		read -p "Stow not installed. Install it [y/n]? " yn
		case $yn in
			[yY][eE][sS]|[yY]) $sudo pacman -S stow;;
			[nN][oO]|[nN]) printf "EXITING\n" && exit;;
			*) printf "Invalid input\n";;
		esac
	fi

	printf "INSTALLING DOTFILES\n"
	git clone https://gitlab.com/peternix/dotfiles $HOME/.dotfiles
	cd $HOME/.dotfiles
	stow *
}

# Installing software
function software{
	printf "INSTALLING SOFTWARE\n"
	yay -S --noconfirm - < packages 
}

# Action prompt
clear
while true; do
	printf "Choose install:\n[1] All\n[2] Dotfiles\n[3] Software\n[4] Ungoogled-chromium (not included in [1])\n\nChoice: "
	read choice
	case $choice in
		1) clear ; dots ; software;;
		2) clear ; dots;;
		3) clear ; software;;
		*) printf "Invalid input\n";;
	esac
done

