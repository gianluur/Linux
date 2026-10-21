#!/usr/bin/env bash
set -euo pipefail

# TPM directory for windows machines
mkdir -p /var/lib/swtpm-localca
chown tss:tss /var/lib/swtpm-localca
restorecon -Rv /var/lib/libvirt /var/log/libvirt /var/lib/swtpm-localca 2>/dev/null || true
