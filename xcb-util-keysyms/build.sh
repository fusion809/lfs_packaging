#!/bin/bash
set -e
name=xcb-util-keysyms
version=$(xcb_ver $name)
depends=(glibc libXau libXdmcp libxcb)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://xorg.freedesktop.org/archive/individual/lib/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
