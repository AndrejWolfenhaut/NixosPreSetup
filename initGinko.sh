#! /usr/bin/env bash

# Wipe existing partitions
# Create GPT partition table
# Create boot, root and swap partitions
sudo parted /dev/nvme0n1 --script -- \
  mklabel gpt \
  mkpart boot fat32 1MB 512MB \
  mkpart root ext4 512MB -8GB \
  mkpart swap linux-swap -8GB 100% \
  set 1 esp on

# Format the boot, root and swap partitions
sudo mkfs.fat -F 32 -n boot /dev/nvme0n1p1
sudo mkfs.ext4 -L root /dev/nvme0n1p2
sudo mkswap -L swap /dev/nvme0n1p3

# Mount newly created partitions
sudo mount /dev/disk/by-label/root /mnt
sudo mkdir -p /mnt/boot
sudo mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
sudo swapon /dev/disk/by-label/swap

# Generate config and install (keep the default config for now...)
sudo nixos-generate-config --root /mnt
sudo nixos-install

# Reboot
read -s -p "Basic NixOS installation complete. Press ENTER to reboot..."
