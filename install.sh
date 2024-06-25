#!/bin/bash



# Unmount all partitions (assuming /dev/sda1 is the root partition and /dev/sda2 is the boot partition)
umount /mnt/boot
umount /mnt

# If you have additional partitions, unmount them as well
# umount /mnt/home (if you have a separate home partition)
# umount /mnt/var (if you have a separate var partition)

# Deactivate swap if it is active
swapoff -a

# Variables
HOSTNAME="arc"
USERNAME="tor"
PASSWORD="paasssword"
TIMEZONE="Asia/Manila"
LOCALE="en_US.UTF-8"
DEVICE="/dev/sda"
ROOT_PART="${DEVICE}1"
SWAP_PART="${DEVICE}2"

# Enable NTP
timedatectl set-ntp true

# Partition the disk (example, adjust as needed)
echo "Partitioning disk..."
parted $DEVICE mklabel gpt
parted $DEVICE mkpart primary ext4 1MiB 100%
parted $DEVICE mkpart primary linux-swap 100% 100%

# Format the partitions
echo "Formatting partitions..."
mkfs.ext4 $ROOT_PART
mkswap $SWAP_PART
swapon $SWAP_PART

# Mount the filesystem
echo "Mounting filesystem..."
mount $ROOT_PART /mnt

# Install base system
echo "Installing base system..."
pacstrap /mnt base linux linux-firmware base-devel linux-headers vim

# Generate fstab
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the new system
echo "Chrooting..."
arch-chroot /mnt /bin/bash <<EOF

# Set timezone
echo "Setting timezone..."
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

# Localization
echo "Setting locale..."
echo "$LOCALE UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf

# Set hostname
echo "Setting hostname..."
echo "$HOSTNAME" > /etc/hostname
echo "127.0.0.1   localhost" >> /etc/hosts
echo "::1         localhost" >> /etc/hosts
echo "127.0.1.1   $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

# Set root password
echo "Setting root password..."
echo "root:$PASSWORD" | chpasswd

# Create a new user
echo "Creating user..."
useradd -m -G wheel $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Install and configure bootloader
echo "Installing bootloader..."
pacman -S --noconfirm grub
grub-install --target=i386-pc $DEVICE
grub-mkconfig -o /boot/grub/grub.cfg

# Install and enable NetworkManager
echo "Installing NetworkManager..."
pacman -S --noconfirm networkmanager
systemctl enable NetworkManager

# Install Xorg and i3
echo "Installing Xorg and i3..."
pacman -S --noconfirm xorg-server xorg-xinit i3-gaps i3status dmenu alacritty

# Install vim and neovim
echo "Installing vim and neovim..."
pacman -S --noconfirm vim neovim

# Configure .xinitrc
echo "Configuring .xinitrc..."
echo "exec i3" > /home/$USERNAME/.xinitrc
chown $USERNAME:$USERNAME /home/$USERNAME/.xinitrc

EOF

# Unmount and reboot
echo "Unmounting and rebooting..."
umount -R /mnt
reboot
