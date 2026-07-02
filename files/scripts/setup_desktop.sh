#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

# TODO: Automate SHA256 detection of the konsave file
DIRECTORY="/etc/bluebuild/theme/konsave/"
KONSAVE_FILE="${DIRECTORY}/desktop.knsv"
EXPECTED_SHA256="7bf80e28fdc052e7d172f531eebeda89ac7b42a33d30a9bcae3e587e74ac41cb"

function check_konsave_installation {
    if ! command -v konsave &>/dev/null; then
        echo "Konsave is not present, installing it now"
        python3 -m pip install konsave
    fi
}

function assemble_knsv_file {
    if [[ ! -f "$KONSAVE_FILE" ]]; then
        echo "Assembling knsv file..."
        cat "${KONSAVE_FILE}".part* > "$KONSAVE_FILE"
    fi
}

function verify_integrity {
    echo "Verifying file integrity…"
    ACTUAL_SHA256=$(sha256sum "$KONSAVE_FILE" | awk '{print $1}')
    
    if [[ "$ACTUAL_SHA256" != "$EXPECTED_SHA256" ]]; then
        echo "Error: Integrity check failed!" >&2
        echo "Expected SHA256: $EXPECTED_SHA256" >&2
        echo "Actual SHA256:   $ACTUAL_SHA256" >&2
        echo "The reassembled file is corrupt or parts are missing." >&2
        rm -f "$KONSAVE_FILE"
        exit 1
    fi
}

check_konsave_installation
assemble_knsv_file
verify_integrity

konsave --import-profile "$KONSAVE_FILE"
konsave --apply desktop