#!/bin/bash
set -euo pipefail

sudo systemctl enable --now nix-daemon
echo "✅ nix-daemon enabled and started."