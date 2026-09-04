#!/bin/bash
set -e
name=vala
version=$(gh_ver GNOME/vala)
majVer=$(echo $version | sed -E 's/.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
blfs_depends=(glib2 graphviz)
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/vala/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
