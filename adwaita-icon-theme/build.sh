#!/bin/bash
set -e
name=adwaita-icon-theme
version=$(gn_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gtk3 gtk4 librsvg)
gn_download "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr
cd ../..
sudo rm -rf /usr/share/icons/Adwaita/
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
