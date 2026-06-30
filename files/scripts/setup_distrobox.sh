#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="utilities"
if /usr/bin/podman container exists "$CONTAINER_NAME"; then
    exit 0
fi

/usr/bin/distrobox assemble create --file /etc/distrobox/utilities.ini