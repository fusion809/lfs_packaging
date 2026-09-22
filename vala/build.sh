#!/bin/bash
set -e
name=vala
version=$(gh_ver GNOME/vala)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(glib2 graphviz)
gn_download $name $version
unpk_enter "$filename" "$direname"
if [[ $(pkgver vala) != $version ]]; then
	sudo rm -rf /usr/lib/vala*-$(pkgver vala)
fi
cmi --prefix=/usr
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
