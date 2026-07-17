#!/usr/bin/env bash
set -euo pipefail

if [ -f /etc/passwd ]; then
    sed -i 's/^\([^:]*:x:1000:[^:]*:[^:]*:\/var\/home\/[^:]*:\)[^:]*$/\1\/usr\/bin\/zsh/' /etc/passwd
    echo "Default shell changed to Zsh for user with UID 1000"
else
    echo "Warning: /etc/passwd not found"
    exit 1
fi