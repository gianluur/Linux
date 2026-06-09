#!/bin/bash
set -ouex pipefail

# 1. Install bare essentials needed only for compiling this specific library
# We turn off weak dependencies to prevent DNF from pulling conflicting driver stacks.
dnf install -y --setopt=install_weak_deps=False \
    meson \
    glib2-devel \
    graphene-devel

# 2. Setup paths and clone repo
BUILD_DIR="/tmp/gnome-rounded-blur-build"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

git clone https://github.com/kancko/gnome-rounded-blur.git
cd gnome-rounded-blur

# 3. Handle Mutter version alignment
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

# 4. Build and install the extension library
meson setup build --prefix=/usr
meson compile -C build
meson install -C build

# 5. Clean up temporary build files and uninstall build-only dependencies
# This keeps your final Bazzite system image small and light.
cd /
rm -rf "$BUILD_DIR"
dnf remove -y meson glib2-devel graphene-devel
dnf clean all