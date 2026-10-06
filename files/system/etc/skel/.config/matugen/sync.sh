#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

write_logs() {
    exec >> /tmp/matugen-sync.log 2>&1
    echo "=== Sync started at $(date) ==="
    echo "PWD: $(pwd)"
    echo "USER: $(whoami)"
    echo "PATH: $PATH"
}

update_theme() {
    KDE_JSON="/tmp/kde-material-you-colors-${USER}.json"
    MATUGEN_JSON="$SCRIPT_DIR/structure.json"
    CONVERTER="$SCRIPT_DIR/kde-to-matugen.py"

    if [[ ! -f "$KDE_JSON" ]]; then
        echo "Error: KDE JSON not found at $KDE_JSON"
        exit 1
    fi

    # Convert KDE JSON to Matugen JSON
    python3 "$CONVERTER" "$KDE_JSON" -o "$MATUGEN_JSON"

    matugen json "$MATUGEN_JSON" --type scheme-vibrant
}

update_icons() {
    local FIND_COLOR_VARIANT="$SCRIPT_DIR/folder-colors.py"
    local FOLDER_COLOR
    FOLDER_COLOR=$(python3 "$FIND_COLOR_VARIANT")
    echo "Detected folder color variant: '$FOLDER_COLOR'"

    if [[ -z "$FOLDER_COLOR" ]]; then
        echo "Error: folder color variant is empty, aborting icon update"
        return 1
    fi

    local ICON_THEME="MacTahoe-${FOLDER_COLOR}-dark"
    echo "Setting icon theme to: $ICON_THEME"

    if [[ ! -d "$HOME/.local/share/icons/$ICON_THEME" \
       && ! -d "/usr/share/icons/$ICON_THEME" ]]; then
        echo "Error: icon theme '$ICON_THEME' not installed, aborting"
        return 1
    fi

    kwriteconfig6 --file kdeglobals --group Icons --key Theme "$ICON_THEME" \
        || kwriteconfig5 --file kdeglobals --group Icons --key Theme "$ICON_THEME"
    kbuildsycoca6 --noincremental 2>/dev/null \
        || kbuildsycoca5 --noincremental 2>/dev/null

    # kde-material-you-colors --iconsdark "$ICON_THEME"
    # kde-material-you-colors --iconslight "$ICON_THEME"

    gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"

    if [[ -f ~/.config/gtk-3.0/settings.ini ]]; then
        sed -i "s/^gtk-icon-theme-name=.*/gtk-icon-theme-name=$ICON_THEME/" ~/.config/gtk-3.0/settings.ini
    fi

    flatpak override --user --env=ICON_THEME="$ICON_THEME"
    flatpak override --user --filesystem=xdg-data/icons:ro
}

write_logs
update_theme
update_icons

echo "=== Sync finished at $(date) ==="