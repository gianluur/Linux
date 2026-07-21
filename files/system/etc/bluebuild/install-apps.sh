#!/bin/bash

# --- Apps to install ---
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
FLATPAK_REMOTE="flathub"

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

echo ""
echo "🎉 All flatpaks processed!"

echo "=== Refreshing Plasma Panel & Icons ==="
if command -v kbuildsycoca6 &>/dev/null; then
    kbuildsycoca6 --noincremental &>/dev/null
elif command -v kbuildsycoca5 &>/dev/null; then
    kbuildsycoca5 --noincremental &>/dev/null
fi

systemctl --user restart plasma-plasmashell.service
echo ""