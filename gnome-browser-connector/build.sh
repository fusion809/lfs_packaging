#!/bin/bash
set -e
name=gnome-browser-connector
homepage="https://gitlab.gnome.org/GNOME/gnome-browser-connector"
description="Native browser connector for integration with extensions.gnome.org"
version=$(gn_ver $name)
depends=(git glib2 gnome-shell libarchive meson pygobject python)
download_git "https://gitlab.gnome.org/GNOME/gnome-browser-connector"
unpk_enter "$name" "$version"
meson_options=(
    --prefix=/usr
)
mni "${meson_options[@]}"
cd ..
rm -rf build
echo "$version" | sudo tee /var/lib/custom-packages/$name
