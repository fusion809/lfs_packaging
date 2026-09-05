#!/bin/bash
set -e
name=libportal
repo=flatpak/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(glib2 gtk3 gtk4 xdg-desktop-portal-gnome)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/releases/download/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
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
