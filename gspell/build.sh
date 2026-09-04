#!/bin/bash
set -e
name=gspell
version=$(gn_ver gspell)
majVer=$(echo $version | sed -E 's/.[0-9]+//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
blfs_depends=(enchant icu gtk3)
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/gspell/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
mni --prefix=/usr --buildtype=release -D gtk_doc=false
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
