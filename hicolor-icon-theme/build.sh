#!/bin/bash
set -e
name=hicolor-icon-theme
repo=xdg/default-icon-theme
version=$(gfd_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://icon-theme.freedesktop.org/releases/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
