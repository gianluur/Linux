#!/bin/bash
set -euo pipefail

# ===== Enable and Start libvirtd =====
sudo systemctl enable --now libvirtd
echo "✅ libvirtd enabled and started."

# ===== Add user to virtualization groups =====
for g in libvirt kvm docker; do
    if ! id -nG "$USER" | grep -qw "$g"; then
        sudo usermod -aG "$g" "$USER"
        echo "✅ Added user to $g group (Log out & back in for changes to take effect)."
    else
        echo "✅ Already in $g group."
    fi
done

# ===== Setup directories for VMs =====
VM_DIR="$HOME/VMs"
mkdir -p "$VM_DIR/Images" "$VM_DIR/Shared" "$VM_DIR/ISOs"

# ===== Configure SELinux for VM storage =====
if command -v getenforce &> /dev/null; then
    if sudo setsebool -P virt_use_home_dir on; then
        echo "✅ SELinux boolean 'virt_use_home_dir' enabled."
    else
        echo "⚠️  SELinux is present but boolean couldn't be set. Check if policycoreutils is installed."
    fi
fi

echo "✅ VM directories created."

# ===== Restrictive ACL setup =====
# Grant execute ONLY to enter $HOME and ~/VMs (cannot list contents)
sudo setfacl -m u:qemu:x "$HOME"
sudo setfacl -m u:qemu:x "$VM_DIR"

# ISO folder: read-only access for files and execution for directories
sudo setfacl -R -m u:qemu:rx "$VM_DIR/ISOs"
sudo setfacl -R -d -m u:qemu:rx "$VM_DIR/ISOs"

# Disk Images & Shared: read-write access
sudo setfacl -R -m u:qemu:rwx "$VM_DIR/Images" "$VM_DIR/Shared"
sudo setfacl -R -d -m u:qemu:rwx "$VM_DIR/Images" "$VM_DIR/Shared"

echo "✅ Storage permissions configured securely."