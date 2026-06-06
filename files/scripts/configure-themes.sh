#!/bin/bash
set -euxo pipefail

# Install GTK theme (Tokyonight, purple, macOS buttons, libadwaita)
cd /tmp/theme-sources/gtk/themes
./install.sh --tweaks macos -t purple -l

# Install icon theme (MacTahoe, purple, bold)
cd /tmp/theme-sources/icons
./install.sh -t purple -b -d /usr/share/icons

# Install cursor theme (MacOS Tahoe)
cp -r /tmp/theme-sources/cursor/MacOS-Tahoe-Cursor /usr/share/icons/

# Optional: update icon caches
gtk-update-icon-cache -f /usr/share/icons/MacTahoe-purple-bold || true
gtk-update-icon-cache -f /usr/share/icons/MacOS-Tahoe-Cursor || true

# Set default GTK settings for new users (via /etc/skel)
mkdir -p /etc/skel/.config/gtk-3.0 /etc/skel/.config/gtk-4.0
cat > /etc/skel/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=Tokyonight-purple
gtk-icon-theme-name=MacTahoe-purple-bold
gtk-cursor-theme-name=MacOS-Tahoe-Cursor
gtk-font-name=Inter 10
EOF
cp /etc/skel/.config/gtk-3.0/settings.ini /etc/skel/.config/gtk-4.0/settings.ini

# Flatpak overrides (system-wide)
flatpak override --filesystem=/usr/share/themes
flatpak override --filesystem=/usr/share/icons
flatpak override --env=XCURSOR_PATH=/usr/share/icons:/usr/share/pixmaps

echo "Themes and Flatpak overrides applied successfully."