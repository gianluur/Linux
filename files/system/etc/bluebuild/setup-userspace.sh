#!/bin/bash

MARKER_FILE="$HOME/.local/share/userspace-setup.done"
if [ -f "$MARKER_FILE" ]; then
    echo "✅ Flatpaks already installed. Exiting."
    sleep 2
    exit 0
fi

echo "=== Finishing configuring your desktop... ==="

echo "=== Installing Apps ==="
./install-apps.sh
echo "=== Done ==="

echo "=== Configuring your shell ==="
zsh -i -c "zinit compile --all; exit"
echo "=== Done ==="

echo "=== Finishing configuring Proton VPN ==="
systemctl daemon-reload
systemctl enable me.proton.vpn.split_tunneling.service
systemctl start me.proton.vpn.split_tunneling.service
echo "=== Done === "

touch "$MARKER_FILE"
rm -f "$HOME/.config/autostart/flatpak-install.desktop"
echo "🛠️  Autostart entry removed. This window will close in 5 seconds."
sleep 5
