#!/bin/bash
set -e
name=fcft
version=$(wget -cqO- https://codeberg.org/dnkl/fcft/tags | grep "/tag/" | head -n 1 | cut -d '"' -f 4 | cut -d '/' -f 6)
lfs_depends=(meson pixman ninja)
blfs_depends=(freetype2 fontconfig)
direname="$name-$version"
filename="$name-$version.tar.gz"

if ! [[ -f "$filename" ]]; then
	wget -c https://codeberg.org/dnkl/fcft/archive/$version.tar.gz -O $filename 
fi
tar xf "$filename"
cd "$name"
meson build --buildtype=release --prefix=/usr
ninja -C build
sudo ninja -C build install
cd ..
rm -rf "$name" "$filename"
echo "$version" > /var/lib/custom-packages/$name
