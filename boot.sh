#!/bin/bash

# Stop script on error
set -e

# Ensure the script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Define the main user (assumed UID 1000)
USER_NAME=$(id -nu 1000)
USER_HOME="/home/$USER_NAME"

echo "============================================="
echo "Phase 2: First Boot Setup"
echo "Running as root. Installing apps for user: $USER_NAME"
echo "============================================="

# --- AUTOMATION FIX: Allow user to run pacman without password temporarily ---
# This prevents yay (running as user) from asking for a password during install.
SUDOERS_FILE="/etc/sudoers.d/99_temp_yay_nopasswd"
echo "$USER_NAME ALL=(ALL) NOPASSWD: /usr/bin/pacman" > "$SUDOERS_FILE"
chmod 0440 "$SUDOERS_FILE"
echo "Temporary sudo permission granted for pacman."
# --------------------------------------------------------------------------------

# 1. Pacman Configuration (Color, ILoveCandy, Multilib)
echo "[1/13] Tweaking Pacman configuration..."
sed -i 's/^#Color/Color/' /etc/pacman.conf
if ! grep -q "^ILoveCandy" /etc/pacman.conf; then
  sed -i '/^Color/a ILoveCandy' /etc/pacman.conf
fi
# Robust Multilib enable
sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
echo "[2/13] Performing full system update..."
pacman -Syu --noconfirm

# 3. Install Build Tools
echo "[3/13] Installing base-devel and cmake..."
pacman -S --needed --noconfirm base-devel cmake

# 4. Install Drivers (Nvidia 580xx)
echo "[5/13] Installing Nvidia drivers (580xx series)..."
runuser -u "$USER_NAME" -- yay -S --noconfirm --needed dkms linux-headers nvidia-580xx-utils nvidia-580xx-dkms lib32-nvidia-580xx-utils

# 5. Install Essential Utilities
echo "[6/13] Installing FFmpeg, 7zip, Ark, Flatpak, and UFW..."
pacman -S --noconfirm ffmpeg p7zip ark flatpak ufw
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
ufw default allow incoming
ufw default allow outgoing
ufw enable
systemctl enable ufw.service

# 6. Install GUI Applications
echo "[7/13] Installing GUI Applications..."
runuser -u "$USER_NAME" -- yay -S --noconfirm floorp-bin localsend-bin seanime-denshi-git hydra-launcher-bin bazaar kitty obsidian code neovim kio-admin

# 7. Install CLI Tools
echo "[8/13] Installing CLI Tools..."
runuser -u "$USER_NAME" -- yay -S --noconfirm zsh fzf zoxide eza starship bat ripgrep

# 8. Install Oh My Zsh
echo "[9/13] Installing Oh My Zsh..."
# We run this as the user to set up their home directory correctly
runuser -u "$USER_NAME" -- sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# ==========================================
# NTFS DRIVES MOUNT & SYMLINKS
# ==========================================
echo "[10/13] Configuring NTFS Drives..."

# 1. Install ntfs-3g driver
# REMOVED: Assuming ntfs-3g is installed beforehand as requested.

# 2. Create Mount Points in /mnt
echo "Creating mount directories in /mnt..."
mkdir -p /mnt/win11
mkdir -p /mnt/extraSSD
mkdir -p /mnt/installed
mkdir -p /mnt/downNmisc
mkdir -p /mnt/videosNbackup
mkdir -p /mnt/webdev
mkdir -p /mnt/games

# 3. Append entries to /etc/fstab
echo "Appending drives to /etc/fstab..."
FSTAB_FILE="/etc/fstab"
if ! grep -q "win11" "$FSTAB_FILE"; then
cat <<EOF >> "$FSTAB_FILE"
# Windows 11
UUID=465A50135A5001DB  /mnt/win11  ntfs-3g  defaults,nofail,user,uid=1000,gid=1000,windows_names,umask=000 0 0
# Extra SSD
UUID=08807EFB807EEE96  /mnt/extraSSD  ntfs-3g  defaults,nofail,user,uid=1000,gid=1000,windows_names,umask=000 0 0
# Installed Apps
UUID=1A5897E85897C145  /mnt/installed  ntfs-3g  defaults,nofail,user,uid=1000,gid=1000,windows_names,umask=000 0 0
# Downloads and Misc
UUID=1A6A180D6A17E473  /mnt/downNmisc  ntfs-3g  defaults,nofail,user,uid=1000,gid=1000,windows_names,umask=000 0 0
# Videos and Backup
UUID=6CDC2FF1DC2FB46C  /mnt/videosNbackup  ntfs-3g  defaults,nofail,user,uid=1000,gid=1000,windows_names,umask=000 0 0
# Web Development
UUID=0FF408350FF40835  /mnt/webdev  ntfs-3g  defaults,nofail,user,uid=1000,gid=1000,windows_names,umask=000 0 0
# Games
UUID=F43C041F3C03DB8C  /mnt/games  ntfs-3g  defaults,nofail,user,uid=1000,gid=1000,windows_names,umask=000 0 0
EOF
fi

# 4. Reload Daemon and Mount Drives
echo "Reloading system daemon and mounting all drives..."
systemctl daemon-reload
mount -a

# 5. Create Symlinks in User Home Directory
echo "Creating symlinks in user home..."
MOUNT_POINTS=("win11" "extraSSD" "installed" "downNmisc" "videosNbackup" "webdev" "games")

for dir in "${MOUNT_POINTS[@]}"; do
    SOURCE="/mnt/$dir"
    TARGET="$USER_HOME/$dir"

    # Create symlink
    ln -sf "$SOURCE" "$TARGET"
    echo "Linked: $TARGET -> $SOURCE"
done

echo "Drives configured and linked."

# ==========================================
# SYSTEM CLEANUP & THEME SETUP
# ==========================================

# Install SDDM Silent Theme and configure it
echo "[12/13] Installing SDDM Silent Theme..."
runuser -u "$USER_NAME" -- yay -S --noconfirm sddm-silent-theme

# 1. Modify metadata.desktop
THEME_DIR="/usr/share/sddm/themes/silent"
METADATA_FILE="$THEME_DIR/metadata.desktop"

if [ -f "$METADATA_FILE" ]; then
    echo "Modifying $METADATA_FILE..."
    # Comment out default config
    sed -i 's/^ConfigFile=configs\/default.conf/#ConfigFile=configs\/default.conf/' "$METADATA_FILE"
    # Uncomment ken config
    sed -i 's/^# ConfigFile=configs\/ken.conf/ConfigFile=configs\/ken.conf/' "$METADATA_FILE"
else
    echo "Warning: Could not find metadata.desktop at $THEME_DIR"
fi

# 2. Configure SDDM in /etc/sddm.conf.d/kde_settings.conf
SDDM_CONF_DIR="/etc/sddm.conf.d"
SDDM_CONF_FILE="$SDDM_CONF_DIR/kde_settings.conf"

echo "Configuring SDDM in $SDDM_CONF_FILE..."
mkdir -p "$SDDM_CONF_DIR"

if [ ! -f "$SDDM_CONF_FILE" ]; then
    touch "$SDDM_CONF_FILE"
fi

if ! grep -q "\[Theme\]" "$SDDM_CONF_FILE"; then
    echo -e "\n[Theme]" >> "$SDDM_CONF_FILE"
fi

if grep -q "^Current=" "$SDDM_CONF_FILE"; then
    sed -i 's/^Current=.*/Current=silent/' "$SDDM_CONF_FILE"
else
    echo "Current=silent" >> "$SDDM_CONF_FILE"
fi

echo "SDDM configured."

# --- AUTOMATION CLEANUP: Revoke temporary sudo permission ---
rm -f "$SUDOERS_FILE"
echo "Temporary sudo permission revoked."
# --------------------------------------------------------------------------------

echo "============================================="
echo "Phase 2 Complete."
echo "Please reboot to load Nvidia drivers and mounts."
echo "After reboot, run Phase 3 (User Customization)."
echo "============================================="
