#!/bin/bash
set -e
name=xdg-desktop-portal-gnome
version=$(gn_ver $name)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gnome-desktop gtk4 libadwaita xdg-desktop-portal xdg-desktop-gtk nautilus)
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/xdg-desktop-portal-gnome/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
