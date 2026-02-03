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

# Cache sudo password once at the start to avoid interruptions later
echo "Caching sudo password..."
sudo -v

# 1. Install Fonts, Icons, Tools, and Bibata Cursor
echo "[1/15] Installing Packages..."
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
echo "[1.1/15] Cleaning unwanted Bibata cursor variants..."
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

# CLEANUP STEP: Remove default Kvantum themes from system folder
echo "[2/15] Cleaning default Kvantum themes from /usr/share/Kvantum..."
sudo find /usr/share/Kvantum -maxdepth 1 -type d -name 'Kv*' -exec sudo rm -rf {} + 2>/dev/null || true

# Install Yet Another Monochrome Icon Theme from Git
echo "[3/15] Installing Custom Icon Theme..."
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
echo "[4/15] Cloning Theme Repo to /tmp..."
cd /tmp
rm -rf Mystical-Blue-Theme
git clone https://github.com/juxtopposed/Mystical-Blue-Theme.git
cd Mystical-Blue-Theme || exit

# 5. Install Color Scheme
echo "[5/15] Installing Color Scheme..."
mkdir -p "$LOCAL_SHARE/color-schemes"
if [ -f "JuxTheme.colors" ]; then
    cp JuxTheme.colors "$LOCAL_SHARE/color-schemes/"
fi

# 6. Install Plasma Style
echo "[6/15] Installing Plasma Style..."
mkdir -p "$LOCAL_SHARE/plasma/desktoptheme"
if [ -f "JuxPlasma.tar.gz" ]; then
    tar -xzvf JuxPlasma.tar.gz -C "$LOCAL_SHARE/plasma/desktoptheme/"
fi

# 7. Install Window Decoration
echo "[7/15] Installing Window Decorations..."
mkdir -p "$LOCAL_SHARE/aurorae/themes"
if [ -f "JuxDeco.tar.gz" ]; then
    tar -xzvf JuxDeco.tar.gz -C "$LOCAL_SHARE/aurorae/themes/"
fi

# 8. Install Kvantum Theme
echo "[8/15] Installing Kvantum Theme to /usr/share/Kvantum..."
sudo mkdir -p /usr/share/Kvantum
if [ -f "NoMansSkyJux.tar.gz" ]; then
    sudo tar -xzvf NoMansSkyJux.tar.gz -C /usr/share/Kvantum/
fi

# 9. Install KDE Modern Clock
echo "[9/15] Installing KDE Modern Clock..."
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

# 10. Install Force Blur
echo "[10/15] Installing Force Blur via Yay..."
yay -S --noconfirm kwin-effects-forceblur

# 11. Install Krohnkite (Tiling)
echo "[11/15] Installing Krohnkite (Dynamic Tiling)..."
cd /tmp
rm -rf Krohnkite
git clone https://github.com/googIyEYES/Krohnkite.git
cd Krohnkite
kpackagetool6 -t KWin/Script -i krohnkite-latest.kwinscript
cd /
rm -rf /tmp/Krohnkite

# 12. Move Specific Wallpapers and Rename
echo "[12/15] Moving and Renaming Wallpapers..."

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

# 13. Install Custom Splashscreen
echo "[13/15] Installing Custom Splashscreen..."
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

# 14. Automate Window Rules
echo "[14/15] Configuring Window Rules..."
RULES_FILE="$CONFIG_DIR/kwinrulesrc"
touch "$RULES_FILE"
CURRENT_COUNT=$(grep "^count=" "$RULES_FILE" | cut -d'=' -f2)
if [ -z "$CURRENT_COUNT" ]; then CURRENT_COUNT=0; fi

# Rule 1: Global Opacity
RULE_ID_1=$CURRENT_COUNT
cat >> "$RULES_FILE" << EOF
[$RULE_ID_1]
Description=Global Opacity
opacityactive=85
opacityinactive=75
wmclassmatch=0
titlematch=0
types=1,2,3,4,5,6,7,8,9,10,11,12,13,14
EOF

# Rule 2: Floorp PIP
RULE_ID_2=$((CURRENT_COUNT + 1))
cat >> "$RULES_FILE" << EOF
[$RULE_ID_2]
Description=Floorp PIP Always On Top
above=true
wmclass=floorp
wmclassmatch=1
titlematch=0
types=1
EOF

NEW_COUNT=$((CURRENT_COUNT + 2))
sed -i "s/^count=.*/count=$NEW_COUNT/" "$RULES_FILE"

# --- Final Config ---
mkdir -p "$CONFIG_DIR/rofi"
cat << 'EOF' > "$CONFIG_DIR/rofi/rofi-toggle"
#!/bin/bash
if pgrep -x "rofi" > /dev/null; then pkill rofi; else rofi -show drun; fi
EOF
chmod +x "$CONFIG_DIR/rofi/rofi-toggle"

kwriteconfig6 --file "$CONFIG_DIR/kwinrc" --group Plugins --key krohnkiteEnabled true
kwriteconfig6 --file "$CONFIG_DIR/kwinrc" --group Plugins --key forceblurEnabled true
kwriteconfig6 --file "$CONFIG_DIR/kwinrc" --group ForceBlur --key BlurApplications "dolphin,spotify,obsidian,code"
qdbus6 org.kde.KWin /KWin reconfigure

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

# --- Better Blur Configuration List ---
echo ""
echo "============================================="
echo "Better Blur Configuration"
echo "============================================="
echo "Please copy the list below and paste it into the"
echo "list of applications for the Better Blur effect:"
echo ""
echo "dolphin"
echo "systemsettings"
echo "zen"
echo "app.zen_browser.zen"
echo "plasmashell"
echo "konsole"
echo "kvantummanager"
echo "org.kde.spectacle"
echo "discord"
echo "org.inkscape.Inkscape"
echo "Yad"
echo "kate"
echo "org.kde.plasma-systemmonitor"
echo "org.kde.ark"
echo "org.kde.discover"
echo "org.kde.haruna"
echo "rofi"
echo "spotify"
echo "steam"
echo "============================================="
