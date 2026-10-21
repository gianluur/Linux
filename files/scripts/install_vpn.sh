#!/usr/bin/env bash
set -euo pipefail

# The reason i installed the VPNs in this file is because they need system access
# and that can't be provided by any flatpak or similar, and also i couldn't even
# install them via the dnf module because they have some post-install script that
# needs the system to be booted, to do some systemd stuff, everything they need is
# getting called at first boot from the script at /etc/bluebuild/setup-vpn.sh

echo "=== Installing Proton VPN ==="
dnf install -y --setopt=tsflags=noscripts proton-vpn-gnome-desktop

echo "=== Installing Netbird ==="
dnf install -y --setopt=tsflags=noscripts netbird netbird-ui gtk4 webkitgtk6.0 xdg-utils
