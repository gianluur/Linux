#!/usr/bin/env bash
set -euo pipefail

echo "========================================="
echo "   🚀 Initializing Userspace Setup...   "
echo "========================================="

/etc/bluebuild/scripts/setup_desktop.sh
/etc/bluebuild/scripts/setup_distrobox.sh

# # 1. Ensure your central Configuration directory exists
# mkdir -p "$HOME/Configuration"

# # 2. Copy the static files from the immutable /etc layer to your home directory if needed
# echo "-> Deploying configurations to ~/Configuration..."
# cp -r /etc/bluebuild/userspace/configs/apps "$HOME/Configuration/Apps"
# cp -r /etc/bluebuild/userspace/configs/system "$HOME/Configuration/System"

# # 3. Execute Ansible
# echo "-> Running Ansible userspace playbook..."
# ansible-playbook /etc/bluebuild/userspace/deploy.yaml

# echo "========================================="
# echo "   ✅ Setup finished! Press Enter to close."
# echo "========================================="
# read -r # This keeps Kitty open so you can read the log!