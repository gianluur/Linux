#!/bin/bash

echo "=== Configuring the necessary services ==="
systemctl daemon-reload
systemctl enable me.proton.vpn.split_tunneling.service
systemctl start me.proton.vpn.split_tunneling.service

echo "=== Adding ProtonVPN to autostart ==="
mkdir -p ~/.config/autostart

cat << 'EOF' > ~/.config/autostart/protonvpn.desktop
[Desktop Entry]
Categories=Network;
Comment=Proton VPN GUI client
Exec=protonvpn-app
Icon=proton-vpn-logo
Name=Proton VPN
StartupWMClass=protonvpn-app
Terminal=false
Type=Application
X-Desktop-File-Install-Version=0.28
EOF

chmod +x ~/.config/autostart/proton.vpn.app.gtk