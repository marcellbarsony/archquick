#!/bin/zsh

clear

# Formatting disks I.

echo "# Formatting disks I.\n"
sleep 5

echo "Formatting P1: /dev/nvme0n1p1 (FAT32)"
mkfs.fat -F32 /dev/nvme0n1p1
sleep 5

echo "Formatting P2: /dev/nvme0n1p2 (ext4)"
mkfs.ext4 /dev/nvme0n1p2
sleep 5
clear

# Encrypted container

echo "# Encrypted container\n"
sleep 5

echo "Creating LUKS container on P3: /dev/nvme0n1p3"
cryptsetup luksFormat /dev/nvme0n1p3
    # Enter encryption password

echo "Unlocking the encrypted container (cryptlvm)"
cryptsetup open --type luks /dev/nvme0n1p3 cryptlvm
    # Enter encryption password
sleep 5
clear

# Logical volumes

echo "# Logical volumes\n"
sleep 5

echo "Creating physical volume on the top of the opened LUKS container"
pvcreate /dev/mapper/cryptlvm
sleep 5

echo "Creating root filesystem: 30GBs - volgroup 0 - cryptroot"
lvcreate -L 30GB volgroup0 -n cryptroot
sleep 5

echo "Creating Home filesystem: 100%FREE - volgroup 0 - crypthome\n"
lvcreate -l 100%FREE volgroup0 -n crypthome

echo "Activating volume groups (modrprobe dm_mod)"
modprobe dm_mod
sleep 5

echo "Scanning for available volume groups"
vgscan
sleep 5

echo "Activating volume groups"
vgchange -ay
sleep 5
clear

# Formatting disks II.

echo "# Formatting disks II.\n"
sleep 5

echo "Formatting /ROOT\n"
sleep 5

echo "Formatting ROOT file system logical volume (ext4 - /dev/volgroup0/cryptroot)"
mkfs.ext4 /dev/volgroup0/cryptroot
sleep 5

echo "Mounting cryptroot to /mnt\n"
mount /dev/volgroup0/cryptroot /mnt
sleep 5

echo "Formatting /BOOT\n"
sleep 5

echo "Creating directory"
mkdir /mnt/boot
sleep 5

echo "Mounting EFI partition\n"
mount /dev/nvme0n1p2 /mnt/boot
sleep 5

echo "formatting /HOME\n"
mkfs.ext4 /dev/volgroup0/crypthome
sleep 5

echo "Creating mount directory for /home"
mkdir /mnt/home
sleep 5

echo "Mounting /home"
mount /dev/volgroup0/crypthome /mnt/home
sleep 5
clear

# fstab

echo "# fstab\n"
sleep 5

echo "Creating fstab directory: /mnt/etc"
mkdir /mnt/etc
echo "Generating fstab config"
genfstab -U -p /mnt >> /mnt/etc/fstab
echo "Checking fstab"
cat /mnt/etc/fstab
sleep 5
clear

# Kernel

echo "# Kernel\n"
sleep 5

echo "Installing essential packages"
pacstrap -i /mnt base linux linux-firmware bash-completion linux-headers base-devel
sleep 5

# Chroot

echo "# Chroot\n"

echo "Changing root to the new Arch system"
arch-chroot /mnt