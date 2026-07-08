#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="utilities"
if podman container exists "$CONTAINER_NAME"; then
    exit 0
fi

distrobox assemble create --file /etc/bluebuild/distrobox/utilities.ini