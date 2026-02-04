#!/bin/bash

if [ "$EUID" -eq 0 ]; then
  echo "Do not run this script as root. Run it as your normal user."
  exit
fi

# Use absolute path for HOME to ensure consistency
HOME_DIR="/home/$USER"
LOCAL_SHARE="$HOME_DIR/.local/share"
CONFIG_DIR="$HOME_DIR/.config"

echo "============================================="
echo "Phase 3: User Customization (Mystical Blue)"
echo "============================================="

# Cache sudo password once at the start
echo "Caching sudo password..."
sudo -v

# 1. Install Fonts, Icons, Tools, and Bibata Cursor
echo "[1/14] Installing Packages..."
yay -S --noconfirm \
  ttf-jetbrains-mono-nerd \
  ttf-0xproto \
  ttf-font-awesome-5 \
  otf-font-awesome-5 \
  rofi \
  kvantum \
  plasma6-applets-panel-colorizer \
  bibata-cursor-theme-bin

# CLEANUP: Remove unwanted Bibata cursor variants
echo "[1.1/14] Cleaning unwanted Bibata cursor variants..."
sudo rm -rf /usr/share/icons/Bibata-Modern-Amber
sudo rm -rf /usr/share/icons/Bibata-Modern-Amber-Right
sudo rm -rf /usr/share/icons/Bibata-Modern-Classic
sudo rm -rf /usr/share/icons/Bibata-Modern-Classic-Right
sudo rm -rf /usr/share/icons/Bibata-Modern-Ice-Right
sudo rm -rf /usr/share/icons/Bibata-Original-Amber
sudo rm -rf /usr/share/icons/Bibata-Original-Amber-Right
sudo rm -rf /usr/share/icons/Bibata-Original-Classic
sudo rm -rf /usr/share/icons/Bibata-Original-Classic-Right
sudo rm -rf /usr/share/icons/Bibata-Original-Ice
sudo rm -rf /usr/share/icons/Bibata-Original-Ice-Right
echo "Kept only Bibata-Modern-Ice."

# CLEANUP: Remove extra system cursor themes
echo "[1.2/14] Cleaning extra system cursor themes..."
sudo rm -rf /usr/share/icons/AdwaitaLegacy
sudo rm -rf /usr/share/icons/breeze_cursors
sudo rm -rf /usr/share/icons/breeze-dark
sudo rm -rf /usr/share/icons/KDE_Classic
sudo rm -rf /usr/share/icons/Oxygen_Black
sudo rm -rf /usr/share/icons/Oxygen_Blue
sudo rm -rf /usr/share/icons/Oxygen_White
sudo rm -rf /usr/share/icons/Oxygen_Yellow
sudo rm -rf /usr/share/icons/Oxygen_Zion

# CLEANUP STEP: Remove default Kvantum themes from system folder
echo "[2/14] Cleaning default Kvantum themes from /usr/share/Kvantum..."
sudo find /usr/share/Kvantum -maxdepth 1 -type d -name 'Kv*' -exec sudo rm -rf {} + 2>/dev/null || true

# CLEANUP STEP: Remove default Kvantum color schemes
echo "[2.1/14] Cleaning Kvantum color schemes..."
sudo rm -rf /usr/share/color-schemes/Kv*

# Install Yet Another Monochrome Icon Theme from Git
echo "[3/14] Installing Custom Icon Theme..."
cd /tmp
rm -rf Yet-Another-Monochrome-Icon-Theme
git clone https://github.com/googIyEYES/Yet-Another-Monochrome-Icon-Theme.git
cd Yet-Another-Monochrome-Icon-Theme
mkdir -p "$LOCAL_SHARE/icons"
if [ -f "monochrome-icon-theme.tar.gz" ]; then
    tar -xzvf monochrome-icon-theme.tar.gz -C "$LOCAL_SHARE/icons/"
    echo "Icon theme installed to $LOCAL_SHARE/icons/"
else
    echo "Error: monochrome-icon-theme.tar.gz not found in repo."
fi

# 4. Clone Mystical Blue Theme
echo "[4/14] Cloning Theme Repo to /tmp..."
cd /tmp
rm -rf Mystical-Blue-Theme
git clone https://github.com/juxtopposed/Mystical-Blue-Theme.git
cd Mystical-Blue-Theme || exit

# 5. Install Color Scheme
echo "[5/14] Installing Color Scheme..."
mkdir -p "$LOCAL_SHARE/color-schemes"
if [ -f "JuxTheme.colors" ]; then
    cp JuxTheme.colors "$LOCAL_SHARE/color-schemes/"
fi

# 6. Install Plasma Style
echo "[6/14] Installing Plasma Style..."
mkdir -p "$LOCAL_SHARE/plasma/desktoptheme"
if [ -f "JuxPlasma.tar.gz" ]; then
    tar -xzvf JuxPlasma.tar.gz -C "$LOCAL_SHARE/plasma/desktoptheme/"
fi

# 7. Install Window Decoration
echo "[7/14] Installing Window Decorations..."
mkdir -p "$LOCAL_SHARE/aurorae/themes"
if [ -f "JuxDeco.tar.gz" ]; then
    tar -xzvf JuxDeco.tar.gz -C "$LOCAL_SHARE/aurorae/themes/"
fi

# 8. Install Kvantum Theme
echo "[8/14] Installing Kvantum Theme to /usr/share/Kvantum..."
sudo mkdir -p /usr/share/Kvantum
if [ -f "NoMansSkyJux.tar.gz" ]; then
    sudo tar -xzvf NoMansSkyJux.tar.gz -C /usr/share/Kvantum/
fi

# 9. Install KDE Modern Clock
echo "[9/14] Installing KDE Modern Clock..."
cd /tmp
rm -rf kde_modernclock
git clone https://github.com/prayag2/kde_modernclock
cd kde_modernclock
kpackagetool6 -i package

# Move Modern Clock to plasmoids directory
echo "Moving Modern Clock to plasmoids directory..."
SOURCE_CLOCK="$LOCAL_SHARE/kpackage/generic/com.github.prayag2.modernclock"
DEST_CLOCK="$LOCAL_SHARE/plasma/plasmoids/"
mkdir -p "$DEST_CLOCK"
if [ -d "$SOURCE_CLOCK" ]; then
    mv "$SOURCE_CLOCK" "$DEST_CLOCK"
    echo "Moved Modern Clock to $DEST_CLOCK"
else
    echo "Warning: Modern Clock source not found at $SOURCE_CLOCK"
fi

# 10. Move Specific Wallpapers and Rename
echo "[10/14] Moving and Renaming Wallpapers..."

WALLPAPER_SOURCE_1="/tmp/Mystical-Blue-Theme/images/illium.png"
WALLPAPER_DEST_1="/usr/share/wallpapers/Blue Area.png"

WALLPAPER_SOURCE_2="/tmp/Mystical-Blue-Theme/images/nms.png"
WALLPAPER_DEST_2="/usr/share/wallpapers/No Mans Sky.png"

if [ -f "$WALLPAPER_SOURCE_1" ]; then
    sudo cp "$WALLPAPER_SOURCE_1" "$WALLPAPER_DEST_1"
    echo "Copied Blue Area.png"
else
    echo "Source $WALLPAPER_SOURCE_1 not found!"
fi

if [ -f "$WALLPAPER_SOURCE_2" ]; then
    sudo cp "$WALLPAPER_SOURCE_2" "$WALLPAPER_DEST_2"
    echo "Copied No Mans Sky.png"
else
    echo "Source $WALLPAPER_SOURCE_2 not found!"
fi

# 11. Install Custom Splashscreen
echo "[11/14] Installing Custom Splashscreen..."
SPLASH_REPO="https://github.com/googIyEYES/ArchSpace-Splashscreen.git"
cd /tmp
rm -rf ArchSpace-Splashscreen
git clone $SPLASH_REPO
cd ArchSpace-Splashscreen
if [ -f "archspace.tar.gz" ]; then
    kpackagetool6 -t Plasma/LookAndFeel -i archspace.tar.gz
else
    echo "Error: archspace.tar.gz not found in the cloned repo."
fi

# 12. Move Rofi Configs from Repo
echo "[12/14] Moving Rofi Configs..."
if [ -d "/tmp/Mystical-Blue-Theme/rofi" ]; then
    mkdir -p "$CONFIG_DIR/rofi"
    # Copy everything inside the rofi folder to .config/rofi
    cp -r /tmp/Mystical-Blue-Theme/rofi/* "$CONFIG_DIR/rofi/"
    echo "Moved Rofi configs."
else
    echo "Rofi config folder not found in repo."
fi

# 13. Delete Unwanted Wallpapers
echo "[13/14] Deleting unwanted wallpapers..."
sudo rm -rf /usr/share/wallpapers/Altai
sudo rm -rf /usr/share/wallpapers/Autumn
sudo rm -rf /usr/share/wallpapers/BytheWater
sudo rm -rf /usr/share/wallpapers/Canopee
sudo rm -rf /usr/share/wallpapers/Cascade
sudo rm -rf /usr/share/wallpapers/Cluster
sudo rm -rf /usr/share/wallpapers/Coast
sudo rm -rf /usr/share/wallpapers/ColdRipple
sudo rm -rf /usr/share/wallpapers/ColorfulCups
sudo rm -rf /usr/share/wallpapers/DarkestHour
sudo rm -rf /usr/share/wallpapers/Elarun
sudo rm -rf /usr/share/wallpapers/EveningGlow
sudo rm -rf /usr/share/wallpapers/FallenLeaf
sudo rm -rf /usr/share/wallpapers/Flow
sudo rm -rf /usr/share/wallpapers/FlyingKonqui
sudo rm -rf /usr/share/wallpapers/Grey
sudo rm -rf /usr/share/wallpapers/Honeywave
sudo rm -rf /usr/share/wallpapers/IceCold
sudo rm -rf /usr/share/wallpapers/Kay
sudo rm -rf /usr/share/wallpapers/Kite
sudo rm -rf /usr/share/wallpapers/Kokkini
sudo rm -rf /usr/share/wallpapers/MilkyWay
sudo rm -rf /usr/share/wallpapers/Next
sudo rm -rf /usr/share/wallpapers/Nexus
sudo rm -rf /usr/share/wallpapers/Nuvole
sudo rm -rf /usr/share/wallpapers/OneStandsOut
sudo rm -rf /usr/share/wallpapers/Opal
sudo rm -rf /usr/share/wallpapers/PastelHills
sudo rm -rf /usr/share/wallpapers/Patak
sudo rm -rf /usr/share/wallpapers/Path
sudo rm -rf /usr/share/wallpapers/Shell
sudo rm -rf /usr/share/wallpapers/summer_1am
sudo rm -rf /usr/share/wallpapers/Volna
echo "Wallpapers cleaned."

# --- Final Config ---
mkdir -p "$CONFIG_DIR/rofi"
# Create toggle script (ensure it exists or overwrite)
cat << 'EOF' > "$CONFIG_DIR/rofi/rofi-toggle"
#!/bin/bash
if pgrep -x "rofi" > /dev/null; then pkill rofi; else rofi -show drun; fi
EOF
chmod +x "$CONFIG_DIR/rofi/rofi-toggle"

echo "============================================="
echo "Automation Complete!"
echo "============================================="
echo "MANUAL STEPS:"
echo "1. Add 'Panel Colorizer' & 'Modern Clock' widgets."
echo "2. Apply Global Theme (Mystical Blue)."
echo "3. Set Application Style (Kvantum -> NoMansSkyJux)."
echo "4. Set Icons (Yet Another Monochrome)."
echo "5. Set Cursors (Bibata Modern Ice)."
echo "6. Set Wallpaper (Blue Area.png or No Mans Sky.png)."
echo "7. Set Splashscreen: System Settings -> Appearance -> Splash Screen."
echo "8. Bind Roi shortcut to: $CONFIG_DIR/rofi/rofi-toggle"
echo "============================================="
