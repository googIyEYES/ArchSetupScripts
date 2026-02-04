#!/bin/bash

# ==========================================
# CONFIGURATION
# ==========================================
# !!! IMPORTANT: CHANGE THIS TO YOUR DRIVE !!!
# Examples: /dev/sda , /dev/nvme0n1
DISK="/dev/sda"

echo "============================================="
echo "Phase 1: Chroot Installation"
echo "============================================="

# 1. Install Essential Packages
echo "[1/5] Installing base packages (Grub, Vim, Git, Reflector, Partition Manager)..."
pacman -S --noconfirm grub os-prober neovim ntfs-3g curl perl git dosfstools mtools partitionmanager

# 3. Configure GRUB Settings
echo "[3/5] Tweaking /etc/default/grub (Timeout & OS-Prober)..."
# Change timeout from 5 to 30 seconds
sed -i 's/^GRUB_TIMEOUT=5/GRUB_TIMEOUT=30/' /etc/default/grub

# Enable OS-Prober (Dual Boot)
if grep -q "#GRUB_DISABLE_OS_PROBER=false" /etc/default/grub; then
  sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
elif ! grep -q "GRUB_DISABLE_OS_PROBER=false" /etc/default/grub; then
  echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
fi

# 4. Install Elegant GRUB Theme
echo "[4/5] Installing Elegant GRUB Theme..."
cd /tmp || exit
rm -rf Elegant-grub2-themes
git clone https://github.com/vinceliuice/Elegant-grub2-themes.git
cd Elegant-grub2-themes || exit
./install.sh -t mojave -p window -i right -c dark -s 1080p -l system
cd /tmp
rm -rf Elegant-grub2-themes

# 5. Install GRUB to Disk
echo "[5/5] Installing GRUB bootloader to $DISK..."
if [ -d /sys/firmware/efi/efivars ]; then
    echo "UEFI System detected."
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
else
    echo "BIOS System detected."
    grub-install --target=i386-pc $DISK
fi
grub-mkconfig -o /boot/grub/grub.cfg

echo "============================================="
echo "Phase 1 Complete."
echo "You can now exit chroot and reboot."
echo "============================================="
