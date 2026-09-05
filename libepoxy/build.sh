#!/bin/bash
set -e
name=libepoxy
version=$(gn_ver libepoxy)
majVer=$(echo $version | sed -E 's/.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(mesa)
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/libepoxy/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
