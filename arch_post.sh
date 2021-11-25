#!/bin/bash

# --------------------------------------------------
# Arch Linux post script
# WARNING: script is under development & hard-coded
# https://wiki.archlinux.org/
# by Marcell Barsony
# --------------------------------------------------

clear

# --------------------------------------------------
# Global variables
# --------------------------------------------------

newline="\n"
read -p "Enter the amount of sleep time in seconds: " waitseconds
wait="sleep ${waitseconds}"
$wait
clear

# --------------------------------------------------
# Helper functions
# --------------------------------------------------

copycheck(){
	if [ "$?" -eq "0" ]
		then
			echo "Successful"
		else
			echo "Unsuccessful: exit code $?"
	fi
}

# --------------------------------------------------
# Configs
# --------------------------------------------------

echo "------------------------------"
echo "# Fetching configs"
echo "------------------------------"
echo -ne $newline

echo "Moving dotfiles to the HOME directory"
echo -ne $newline
git clone https://github.com/marcellbarsony/dotfiles.git $HOME/.config
clear

# --------------------------------------------------
# Install necessary applications
# --------------------------------------------------

# https://wiki.archlinux.org/title/List_of_applications

echo "------------------------------"
echo "# Installing applications"
echo "------------------------------"
echo -ne $newline

echo "# ZSH"
echo -ne $newline
sudo pacman -S --noconfirm zsh zsh-syntax-highlighting
$wait
clear

echo "# X11 - Xorg"
echo -ne $newline
sudo pacman -S --noconfirm xorg-server xorg-xinit xorg-xprop arandr
$wait
clear

echo "# Terminal - Alacritty"
echo -ne $newline
sudo pacman -S --noconfirm alacritty
$wait
clear

echo "# Browser - Firefox"
echo -ne $newline
sudo pacman -S --noconfirm firefox
$wait
clear

echo "# Intel firmware"
echo -ne $newline
sudo pacman -S --noconfirm intel-ucode xf86-video-intel
$wait
clear

echo "# CLI Tools"
echo -ne $newline
sudo pacman -S --noconfirm github-cli bitwarden-cli
$wait
clear

echo "Programming languages"
echo -ne $newline
sudo pacman -S --noconfirm python python-pip rust
$wait
clear

echo "# Sound system - ALSA & Pulseaudio & Sof"
echo -ne $newline
sudo pacman -S --noconfirm alsa alsa-utils alsa-firmware # ALSA
sudo pacman -S --noconfirm pulseaudio pulseaudio-alsa pavucontrol sof-firmware # Pulesaudio - sof
$wait
clear

echo "# Additional tools"
echo -ne $newline
sudo pacman -S --noconfirm htop bpytop neofetch unclutter man-db tldr
$wait
clear

echo "# Wallpaper & Colors"
echo -ne $newline
sudo pacman -S --noconfirm xwallpaper
$wait
clear

### PARU

echo "# AUR helper - PARU"
# https://github.com/Morganamilo/paru
echo -ne $newline
git clone https://aur.archlinux.org/paru.git $HOME/.local/src/paru
cd $HOME/.local/src/paru
makepkg -si --noconfirm
cd $HOME
clear

echo "Fonts"

echo "# Starship prompt"
echo -ne $newline
cd $HOME/.local/src/
mkdir starship
cd starship
sh -c "$(curl -fsSL https://starship.rs/install.sh)"

#echo "# Spaceship prompt"
#echo -ne $newline
#paru -S --noconfirm spacehip-prompt-git
#$wait
#clear

# echo "VS Codium"
# echo -ne $newline
# paru -S --noconfirm vscodium
# clear

# echo "Joplin"
# echo -ne $newline
# paru -S --noconfirm joplin-desktop
# clear

# --------------------------------------------------
# Bitwarden
# --------------------------------------------------

echo "------------------------------"
echo "# Bitwarden"
echo "------------------------------"
echo -ne $newline

# RBW by doy - https://github.com/doy/rbw
# sudo pacman -S --noconfirm rbw

# read -p "? 2FA code: " bw2fa
# bwsession=`bw login --method 0 --code $bw2fa | grep "export BW_SESSION" | cut -c 3-`
# eval $bwsession
clear

# --------------------------------------------------
# Configs
# --------------------------------------------------

echo "------------------------------"
echo "# Systemd"
echo "------------------------------"
echo -ne $newline

echo "Copying logind.conf"
sudo cp $HOME/.config/systemd/logind.conf /etc/systemd/
copycheck
$wait
clear

echo "------------------------------"
echo "# ZSH"
echo "------------------------------"
echo -ne $newline

echo "Changing shell to ZSH"
echo -ne $newline
chsh -s /usr/bin/zsh
$wait
echo -ne $newline

echo "Copying zshenv"
sudo cp $HOME/.config/zsh/global/zshenv /etc/zsh/zshenv
copycheck
$wait
echo -ne $newline

echo "Copying zprofile"
sudo cp $HOME/.config/zsh/global/zprofile /etc/zsh/zprofile
copycheck
$wait
echo -ne $newline

echo "------------------------------"
echo "# Pacman"
echo "------------------------------"
echo -ne $newline

echo "Copying pacman.conf"
sudo cp $HOME/.config/pacman/pacman.conf /etc/
copycheck
$wait
clear

echo "------------------------------"
echo "# Suckless"
echo "------------------------------"
echo -ne $newline

echo "Cloning 'dwm' repository"
echo -ne $newline
git clone https://github.com/marcellbarsony/dwm.git $HOME/.local/src/dwm
$wait
echo -ne $newline

echo "Cloning 'st' repository"
echo -ne $newline
git clone https://github.com/marcellbarsony/st.git $HOME/.local/src/st
$wait
echo -ne $newline

echo "Cloning 'dmenu' repository"
echo -ne $newline
git clone https://github.com/marcellbarsony/dmenu.git $HOME/.local/src/dmenu
$wait
echo -ne $newline

echo "Cloning 'slstatus' repository"
echo -ne $newline
git clone https://github.com/marcellbarsony/slstatus.git $HOME/.local/src/slstatus
$wait
echo -ne $newline
clear

echo "Changing directory to ~/.local/src/dwm & compiling"
echo -ne $newline
cd $HOME/.local/src/dwm
sudo make clean install
$wait
clear

echo "Changing directory to ~/.local/src/st & compiling"
echo -ne $newline
cd $HOME/.local/src/st
sudo make clean install
$wait
clear

echo "Changing directory to ~/.local/src/dmenu & compiling"
echo -ne $newline
cd $HOME/.local/src/dmenu
sudo make clean install
$wait
clear

echo "Changing directory to ~/.local/src/slstatus & compiling"
echo -ne $newline
cd $HOME/.local/src/slstatus
sudo make clean install
$wait
clear

echo "--------------------------------------------------"
echo "# Cleaning up installation & HOME"
echo "--------------------------------------------------"
echo -ne $newline

echo "Moving ~/.cargo to ~/.local/share"
mkdir $HOME/.local/share/cargo
mv $HOME/.cargo $HOME/.local/share/cargo

echo "Removing bash files form HOME"
rm -rf .bash*
copycheck
$wait

echo "Removing dotfiles from /ROOT"
sudo rm -rf /dotfiles
copycheck
$wait

echo "Removing installation script from /ROOT"
sudo rm -rf /arch
copycheck
$wait
clear

# --------------------------------------------------
# REBOOT
# --------------------------------------------------

# $wait
# sudo reboot now
