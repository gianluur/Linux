#!/bin/bash

FLATPAKS=(
    app.zen_browser.zen # Browser
    org.kde.kcalc # Calculator
    org.onlyoffice.desktopeditors # Office Suite
    com.obsproject.Studio # Video Recording
    org.kde.okular # PDF Reader
    org.kde.gwenview # Image Viewer
    org.videolan.VLC # Audio & Video Player
    md.obsidian.Obsidian # Notes
    org.localsend.localsend_app # File Sharing
    dev.vencord.Vesktop # Discord
    it.mijorus.gearlever # AppImage handling
    com.ranfdev.DistroShelf # Distrobox handling
    com.github.tchx84.Flatseal # Flatpak permissions
    org.fedoraproject.MediaWriter # ISO Burner
    org.freedesktop.Piper # Logitech
)

# --- Configuration ---
MARKER_FILE="$HOME/.local/share/flatpak-installed.done"
FLATPAK_REMOTE="flathub"

# --- Exit if already done ---
if [ -f "$MARKER_FILE" ]; then
    echo "✅ Flatpaks already installed. Exiting."
    sleep 2
    exit 0
fi

# --- Wait for network (just in case autostart runs too early) ---
echo "⏳ Waiting for network connection..."
until ping -c 1 8.8.8.8 &>/dev/null; do
    sleep 2
done
echo "✅ Network is up."

# --- Ensure Flathub remote exists ---
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# --- Install each flatpak with visible progress ---
echo ""
echo "📦 Starting Flatpak installations..."
echo "----------------------------------------"

for pkg in "${FLATPAKS[@]}"; do
    # Check if already installed
    if flatpak list --user --app | grep -q "$pkg"; then
        echo "⏩ $pkg already installed. Skipping."
        continue
    fi

    echo "⬇️  Installing: $pkg ..."
    if flatpak install --user -y "$FLATPAK_REMOTE" "$pkg"; then
        echo "✅ Success: $pkg"
    else
        echo "❌ FAILED: $pkg (check log above)"
    fi
    echo "----------------------------------------"
done

# --- Mark as complete and clean up the autostart file ---
touch "$MARKER_FILE"
echo ""
echo "🎉 All flatpaks processed!"

# Remove the .desktop file so it never runs again
rm -f "$HOME/.config/autostart/flatpak-install.desktop"

echo "🛠️  Autostart entry removed. This window will close in 5 seconds."
sleep 5

echo "trying to do protonvpn stuff"
systemctl daemon-reload
systemctl enable me.proton.vpn.split_tunneling.service
systemctl start me.proton.vpn.split_tunneling.service