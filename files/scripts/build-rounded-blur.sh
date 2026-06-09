#!/bin/bash
set -ouex pipefail

# 1. Install build dependencies needed for Fedora/Bazzite
# We use rpm-ostree to handle package management safely during a BlueBuild run
dnf install -y glib2-devel meson mutter-devel gobject-introspection git bc gcc C-development

# 2. Setup paths and clone repo
BUILD_DIR="/tmp/gnome-rounded-blur-build"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

git clone https://github.com/kancko/gnome-rounded-blur.git
cd gnome-rounded-blur

# 3. Handle Mutter version alignment (Extracted from the original script logic)
MUTTER_SYS_VER=$(mutter --version | grep -o -P '(?<=mutter ).*' | sed -e 's/"//g' -e "s/'//g" -e 's/\..*//g')
HARDCODE_MUTTER_SYS_VER=$(cat meson.build | grep -o -P '(?<=mutter_req = ).*' | sed -e 's/"//g' -e "s/'//g" -e 's/\..*//g' -e 's/>//g' -e 's/=//g' -e 's/ //g')
MUTTER_API_REPO_VER=$(cat meson.build | grep -o -P '(?<=mutter_api_version = ).*' | sed -e 's/"//g' -e "s/'//g" -e 's/ //g')

if [[ "$MUTTER_SYS_VER" -ge "$HARDCODE_MUTTER_SYS_VER" ]]; then
    DIFF_VALUE=$(echo "$MUTTER_SYS_VER - $HARDCODE_MUTTER_SYS_VER" | bc)
    DIFF_VALUE_2=$(echo "$MUTTER_API_REPO_VER + $DIFF_VALUE" | bc)
    sed -i -e '0,/'"mutter_api_version = ""$MUTTER_API_REPO_VER"'/{s/'"$MUTTER_API_REPO_VER"'/'"$DIFF_VALUE_2"'/g}' meson.build
else
    DIFF_VALUE=$(echo "$HARDCODE_MUTTER_SYS_VER - $MUTTER_SYS_VER" | bc)
    DIFF_VALUE_2=$(echo "$MUTTER_API_REPO_VER - $DIFF_VALUE" | bc)
    sed -i -e '0,/'"mutter_req = ""$HARDCODE_MUTTER_SYS_VER"'/{s/'"$HARDCODE_MUTTER_SYS_VER"'/'"$MUTTER_SYS_VER"'/g}' meson.build
    sed -i -e '0,/'"mutter_api_version = ""$MUTTER_API_REPO_VER"'/{s/'"$MUTTER_API_REPO_VER"'/'"$DIFF_VALUE_2"'/g}' meson.build
fi

# 4. Build the project with meson
# We pass --prefix=/usr explicitly because Fedora systems map libraries to /usr/lib64
meson setup build --prefix=/usr
meson compile -C build

# 5. Install the library directly into the container filesystem
# Unlike standard installations, the container file system at /usr *is* writable 
# during the exact moment BlueBuild is compiling your image layers!
meson install -C build

# 6. Cleanup build dependencies and temporary source files 
# This prevents inflating your atomic image size with unnecessary build tools
cd /
rm -rf "$BUILD_DIR"
dnf remove -y glib2-devel meson mutter-devel gobject-introspection git bc gcc C-development