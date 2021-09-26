#!/bin/zsh

# --------------------------------------------------
# Variables
# --------------------------------------------------

newline="\n"

# --------------------------------------------------
# User creation
# --------------------------------------------------

echo "------------------------------"
echo "# Create user account"
echo "------------------------------"
sleep 5
echo -ne $newline

read -p "Enter your username" username
echo "Add new user ${username}"
useradd -m ${username}
sleep 5
echo -ne $newline

echo "Enter the password of ${username}"
passwd ${username}
sleep 3
clear

# --------------------------------------------------
# User group management
# --------------------------------------------------

echo "------------------------------"
echo "# User group management"
echo "------------------------------"
sleep 5
echo -ne $newline

echo "Adding ${username} to basic groups"
usermod -aG wheel,audio,video,optical,storage ${username}
sleep 5
echo -ne $newline

echo "Verifying group memebership"
id ${username}
sleep 5
echo -ne $newline

echo "Visudo"
echo -ne $newline
echo "Allowing standard users to run commands as root"
echo -ne $newline
sleep 3
cp /linux/cfg/sudoers.tmp /etc/sudoers.tmp # !!!!!!!!!!
if [ "$?" -eq "0" ]
	then
	    echo "Copying visudo - Successful"
	else
	    echo "Copying visudo - Unsuccessful: exit code $?"
fi
sleep 5
echo -ne $newline


# --------------------------------------------------
# Install necessary applications
# --------------------------------------------------

echo "------------------------------"
echo "# Installing applications"
echo "------------------------------"
sleep 5
echo -ne $newline

echo "Window manager: DWM "
sleep 3
echo -ne $newline
pacman -S dwm
clear

echo "dmenu"
sleep 3
echo -ne $newline
pacman -S dmenu
clear

echo "Display server: Xorg-xinit"
sleep 3
echo -ne $newline
pacman -S xorg-xinit
clear

echo "Display server: Xorg"
sleep 3
echo -ne $newline
pacman -S xorg
clear

echo "Sound tools: Alsa, Pulse, Sof"
sleep 3
echo -ne $newline
pacman -S alsa alsa-utils alsa-firmware alsa-ucm-conf alsamixer pulseaudio pavucontrol sof-firmware
clear

echo "Terminal emulator: st"
sleep 3
echo -ne $newline
pacman -S st
clear

echo "Browser"
sleep 3
echo -ne $newline
pacman -S firefox
clear

echo "Network tools"
sleep 3
echo -ne $newline
pacman -S networkmanager wpa_supplicant wireless_tools netctl dialog
echo "Enabling Network manager"
sleep 3
echo -ne $newline
systemctl enable NetworkManager
sleep 3
clear

echo "Intel firmware"
sleep 3
echo -ne $newline
pacman -S intel-ucode xf86-video-intel mesa
clear

echo "Base devel"
sleep 3
echo -ne $newline
pacman -S base-devel
clear

# --------------------------------------------------
# Xorg - xinit
# --------------------------------------------------

echo "------------------------------"
echo "# Xorg - xinit"
echo "------------------------------"
sleep 5
echo -ne $newline

echo "Copying xinitrc"
cp /etc/X11/xinit/xinitrc /home/marci/.xinitrc
if [ "$?" -eq "0" ]
	then
	    echo "Copying xinitrc - Successful"
	else
	    echo "Copying xinitrc - Unsuccessful: exit code $?"
fi
sleep 5
echo -ne $newline

echo "Don't forget to edit the ~/.xinitrc file."
sleep 10