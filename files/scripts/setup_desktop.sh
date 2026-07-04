#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

KNSV_PARTS_DIRECTORY="/etc/bluebuild/theme/konsave"
KNSV_FILE_DIRECTORY="/tmp/bluebuild/konsave"
KNSV_FILE_NAME="desktop.knsv"
KNSV_FILE="${KNSV_FILE_DIRECTORY}/${KNSV_FILE_NAME}"

EXPECTED_SHA256="e94e7f6b202c9a8cadc6bf70f7a671da2c6bd53000a1944944809d325592f9b4"

function check_konsave_installation {
    echo "Checking konsave installation..."
    if ! command -v konsave &>/dev/null; then
        echo "Konsave is not present, installing it now..."
        python3 -m pip install --user konsave
        echo "Konsave installed successfully."
    else
        echo "Konsave is already installed."
    fi
}

function assemble_knsv_file {
    echo "Assembling knsv file..."

    mkdir -p "$KNSV_FILE_DIRECTORY"

    if [[ -f "$KNSV_FILE" ]]; then
        echo "The file was already assembled."
        return 0
    fi

    if ! ls "${KNSV_PARTS_DIRECTORY}/${KNSV_FILE_NAME}".part* &>/dev/null; then
        echo "Error: No parts found in ${KNSV_PARTS_DIRECTORY}!" >&2
        exit 1
    fi

    cat "${KNSV_PARTS_DIRECTORY}/${KNSV_FILE_NAME}".part* > "$KNSV_FILE"
    echo "Assembling completed."
}

function verify_integrity {
    echo "Verifying file integrity…"
    ACTUAL_SHA256=$(sha256sum "$KNSV_FILE" | awk '{print $1}')

    if [[ "$ACTUAL_SHA256" != "$EXPECTED_SHA256" ]]; then
        echo "Error: Integrity check failed!" >&2
        echo "Expected SHA256: $EXPECTED_SHA256" >&2
        echo "Actual SHA256:   $ACTUAL_SHA256" >&2
        echo "The reassembled file is corrupt or parts are missing." >&2
        rm -f "$KNSV_FILE"
        exit 1
    fi
    echo "Integrity check passed."
}

function setup_konsave {
    check_konsave_installation
    assemble_knsv_file
    verify_integrity

    konsave --import-profile "$KNSV_FILE"
    konsave --apply desktop
}

function move_klassy_configs {
    cp /etc/bluebuild/theme/klassy/* ~/.config/klassy
}

setup_konsave
move_klassy_configs