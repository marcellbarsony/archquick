A personal Arch Linux installation script

## Important note

This script is currently **under development** and it is **not production-ready**. It is recommended to not to use it in its current state.

Please note that this script is **hard-coded** for the time being.

## Philosophy

This script ships an automated installation sequence that follows the [Arch Installation guide](https://wiki.archlinux.org/title/installation_guide) and the [Arch Principles](https://wiki.archlinux.org/title/Arch_Linux#Principles). 

Designed to ship a minimal, lightweight and security-focused Arch system.

For the documentation, please refer to the [Wiki page](https://github.com/marcellbarsony/linux/wiki "Wiki - Marci's Arch config") of my config.

## Features

- UEFI
- GRUB
- LVM on LUKS
- Network Manager
- Xorg
- dwm: window manager
- st: terminal
- dmenu: app launcher


## Installation guide

### Base system

1.) Download the [Arch ISO](https://archlinux.org/download/) and create a bootable media

2.) Verify the signature and boot the live environment

3.) Install Git   

`pacman -Sy git`

4.) Clone this repository

`git clone https://github.com/marcellbarsony/arch.git`

5.) Launch the installation script

`bash arch.sh`

### Chroot environment

1.) Clone this repository

`git clone https://github.com/marcellbarsony/arch.git`

2.) Launch the chroot script

`bash arch_chroot.sh`

### Post-installation

1.) Reboot the machine and detach the installation disk

2.) Log in as a normal user

3.) Launch the post-installation script

`bash arch_post.sh`
