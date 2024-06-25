#!/bin/bash

# Set timezone to Asia/Manila
ln -sf /usr/share/zoneinfo/Asia/Manila /etc/localtime
hwclock --systohc

# Set locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf

# Set hostname
# echo "myhostname" > /etc/hostname
# echo "127.0.0.1   localhost" >> /etc/hosts
# echo "::1         localhost" >> /etc/hosts
# echo "127.0.1.1   myhostname.localdomain myhostname" >> /etc/hosts

# Set root password
# echo "Setting root password..."
# passwd

# Create user 'tor' with password 'password'
echo "Creating user 'tor'..."
useradd -m -G wheel tor
echo "tor:password" | chpasswd
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel

# Install and configure bootloader (assuming using GRUB)
# pacman -S --noconfirm grub
# grub-install --target=i386-pc /dev/sda  # Replace /dev/sda with your disk
# grub-mkconfig -o /boot/grub/grub.cfg

# Enable NetworkManager
# pacman -S --noconfirm networkmanager
# systemctl enable NetworkManager

# Install Xorg and i3 (if needed)
# pacman -S --noconfirm xorg-server xorg-xinit i3-gaps i3status dmenu alacritty
pacman -S --noconfirm xorg-server xorg-xinit i3blocks i3-wm dmenu i3lock i3status lightdm lightdm-gtk-greeter alacritty i3-gaps
# Install vim and neovim
pacman -S --noconfirm vim neovim

# Configure .xinitrc for user 'tor'
echo "exec i3" > /home/tor/.xinitrc
chown tor:tor /home/tor/.xinitrc

# Final message and reboot
echo "Installation completed. Rebooting..."
sleep 3
reboot
