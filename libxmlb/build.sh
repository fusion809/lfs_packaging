#!/bin/bash
set -e
name=libxmlb
repo="hughsie/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(glib2 glibc libffi pcre2 systemd util-linux xz zlib zstd)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/hughsie/libxmlb/releases/download/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
mni --prefix=/usr --buildtype=release -D gtkdoc=false
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
