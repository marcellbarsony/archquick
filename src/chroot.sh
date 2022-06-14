#!/bin/bash

rootpassword(){

  password=$(whiptail --passwordbox "Root password" --title "ROOT" --nocancel 8 78 3>&1 1>&2 2>&3)

  password_confirm=$(whiptail --passwordbox "Root password confirm" --title "ROOT" --nocancel 8 78 3>&1 1>&2 2>&3)

  if [ ! ${password} ] || [ ! ${password_confirm} ]; then
      whiptail --title "ERROR" --msgbox "Root password empty." 8 78
      rootpassword
  fi

  if [ ${password} != ${password_confirm} ]; then
      whiptail --title "ERROR" --msgbox "Root password did not match." 8 78
      rootpassword
  fi

  error=$(echo "root:${password}" | chpasswd 2>&1 )

  if [ $? != "0" ]; then
    whiptail --title "ERROR" --yesno "${error}\nExit status: $?" --yes-button "Retry" --no-button "Exit" 18 78
    case $? in
      0)
        rootpassword
        ;;
      1)
        exit 1
        clear
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac
  fi

  useraccount

}

useraccount(){

  username=$(whiptail --inputbox "" --title "User account" --nocancel 8 39 3>&1 1>&2 2>&3)

  if [ ! ${username} ] || [ ${username} == "root" ]; then
    whiptail --title "ERROR" --msgbox "Username cannot be empty or [root]." 8 78
    useraccount
  fi

  useradd -m ${username}
  userpassword

}

userpassword(){

  password=$(whiptail --passwordbox "User password [${username}]" --title "USER" --nocancel 8 78 3>&1 1>&2 2>&3)

  password_confirm=$(whiptail --passwordbox "User password confirm [${username}]" --title "USER" --nocancel 8 78 3>&1 1>&2 2>&3)

  if [ ! ${password} ] || [ ! ${password_confirm} ]; then
      whiptail --title "ERROR" --msgbox "User password empty." 8 78
      userpassword
  fi

  if [ ${password} != ${password_confirm} ]; then
      whiptail --title "ERROR" --msgbox "User password did not match." 8 78
      userpassword
  fi

  error=$(echo "${username}:${password}" | chpasswd 2>&1 )

  if [ $? != "0" ]; then
    whiptail --title "ERROR" --yesno "${error}\nExit status: $?" --yes-button "Retry" --no-button "Exit" 18 78
    case $? in
      0)
        userpassword
        ;;
      1)
        exit 1
        clear
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac
  fi

  usergroup

}

usergroup(){

  error=$(usermod -aG wheel,audio,video,optical,storage ${username} 2>&1)

  if [ $? != "0" ]; then
    whiptail --title "ERROR" --yesno "${error}\nExit status: $?" --yes-button "Retry" --no-button "Exit" 18 78
    case $? in
      0)
        usergroup
        ;;
      1)
        exit 1
        clear
        ;;
      *)
        echo "Exit status $?"
        ;;
    esac
  fi

  membership=$(groups ${username})

  whiptail --title "GROUP INFO" --msgbox "${username} has been added to the following groups:\n${membership}" 8 78

  domainname

}

domainname(){

  nodename=$(whiptail --inputbox "" --title "Hostname" --nocancel 8 39 3>&1 1>&2 2>&3)

  if [ ! ${nodename} ]; then
    whiptail --title "ERROR" --msgbox "Hostname cannot be empty." 8 78
    nodename
  fi

  hostnamectl set-hostname ${nodename}

  if [ "$?" != "0" ]; then
    whiptail --title "ERROR" --msgbox "Hostname cannot be set.\nExit status: $?" 8 78
  fi

  hosts

}

hosts(){

  echo "127.0.0.1        localhost" > /etc/hosts
  echo "::1              localhost" >> /etc/hosts
  echo "127.0.1.1        ${nodename}" >> /etc/hosts

  sudoers

}

sudoers(){

  # Uncomment %wheel group
  sed 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers > /etc/sudoers.new
  export EDITOR="cp /etc/sudoers.new"
  visudo
  rm /etc/sudoers.new

  # Enable insults
  sed '71 i Defaults:%wheel insults' /etc/sudoers > /etc/sudoers.new
  export EDITOR="cp /etc/sudoers.new"
  visudo
  rm /etc/sudoers.new

  initramfs

}

initramfs(){

  # LVM support
  pacman -Qi lvm2 > /dev/null
  if [ "$?" == "0" ]; then
    sed -i "s/block filesystems/block encrypt lvm2 filesystems/g" /etc/mkinitcpio.conf
  fi

  mkinitcpio -p linux

  locale

}

locale(){

  # Locale.gen
  sed -i '/#en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen

  # Locale.conf
  echo "LANG=en_US.UTF-8" > /etc/locale.conf

  # Generate config
  locale-gen

  grub

}

grub(){

  pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools

  # GRUB - Install
  grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck

  # LVM support
  pacman -Qi lvm2 > /dev/null
  if [ "$?" != "0" ]; then

    sed -i /GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=/dev/nvme0n1p3:volgroup0:allow-discards\ loglevel=3\ quiet\ video=1920x1080\" /etc/default/grub

    sed -i '/#GRUB_ENABLE_CRYPTODISK=y/s/^#//g' /etc/default/grub

  fi

  # GRUB - Generate config
  grub-mkconfig -o /boot/grub/grub.cfg

  #mkdir /boot/EFI
  #mount /dev/sda1 /boot/EFI #VM
  #mount /dev/nvme0n1p1 /boot/EFI #PM

  virtualmodules

}

virtualmodules(){

  pacman -Qi virtualbox-guest-utils > /dev/null
  if [ "$?" == "0" ]; then

    # VirtualBox service
    systemctl enable vboxservice.service

    # VirtualBox kernel modules
    modprobe -a vboxguest vboxsf vboxvideo

    # VirtualBox guest services
    VBoxClient-all

  fi

  supportpackages

}

supportpackages(){

  # Install packages
  pacman -S --noconfirm networkmanager openssh

  # Network Manager
  systemctl enable NetworkManager

  # Open SSH
  systemctl enable sshd.service

}

rootpassword
