#!/bin/bash
set -e
name=xdg-desktop-portal-gnome
version=$(gn_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gnome-desktop gtk4 libadwaita nautilus xdg-desktop-gtk xdg-desktop-portal)
gn_download "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
