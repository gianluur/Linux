#!/usr/bin/env bash
set -euo pipefail

echo "========================================="
echo "   🚀 Initializing Userspace Setup...   "
echo "========================================="

echo "========================================="
echo "     Configuring Distrobox...     "
echo "========================================="

/etc/bluebuild/scripts/setup_distrobox.sh

echo "========================================="
echo "     Changing Shell...     "
echo "========================================="

/etc/bluebuild/scripts/setup_shell.sh