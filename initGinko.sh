#! /usr/bin/env bash

echo
echo "Recreating GPT partition table,"
echo "creating boot, root and swap partitions..."
echo
sudo parted /dev/nvme0n1 --script -- \
  mklabel gpt \
  mkpart boot fat32 1MB 512MB \
  mkpart root ext4 512MB -8GB \
  mkpart swap linux-swap -8GB 100% \
  set 1 esp on

echo
echo "Formatting boot partition..."
echo
sudo mkfs.fat -F 32 -n boot /dev/nvme0n1p1

echo
echo "Formatting root partition..."
echo
sudo mkfs.ext4 -L root /dev/nvme0n1p2

echo
echo "Formatting swap partition..."
echo
sudo mkswap -L swap /dev/nvme0n1p3

echo
echo "Mounting root partition at /mnt..."
echo
sudo mount /dev/disk/by-label/root /mnt

echo
echo "Mounting boot partition at /mnt/boot..."
echo
sudo mkdir -p /mnt/boot
sudo mount -o umask=077 /dev/disk/by-label/boot /mnt/boot

echo
echo "Mounting swap partition..."
echo
sudo swapon /dev/disk/by-label/swap

echo
echo "Generating NixOS config..."
echo
sudo nixos-generate-config --root /mnt

echo
echo "Installing NixOS..."
echo
sudo nixos-install

read -s -p "Basic NixOS installation complete. Press ENTER to reboot..."
sudo reboot
