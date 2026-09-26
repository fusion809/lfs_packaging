#!/bin/bash
set -e
name=libportal
homepage="https://github.com/flatpak/libportal"
description="GIO-style async APIs for most Flatpak portals"
repo=flatpak/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(glib2 gtk3 gtk4 xdg-desktop-portal-gnome)
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
#gap_patches $name
sed -i "s/requires: \[qt6_dep/requires: ['Qt6Core', 'Qt6Gui', 'Qt6Widgets'/" libportal/meson.build
export PKG_CONFIG_PATH="/opt/qt6/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
meson_options=(--prefix=/usr       \
            --buildtype=release \
            -D vapi=false       \
	    -D docs=false)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
