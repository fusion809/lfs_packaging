#!/bin/bash
set -e
name=adwaita-icon-theme
version=$(gn_ver $name)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gtk3 gtk4 librsvg)
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/adwaita-icon-theme/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
mni --prefix=/usr
cd ../..
sudo rm -rf /usr/share/icons/Adwaita/
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
