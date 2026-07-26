#!/bin/bash
set -e
name=fuzzel
version=$(wget -cqO- https://codeberg.org/dnkl/fuzzel/tags | grep "/tag/" | head -n 1 | cut -d '"' -f 4 | cut -d '/' -f 6)
direname="$name-$version"
filename="$direname.tar.gz"
depends=(scdoc fcft)
blfs_depends=(fontconfig libpng libxkbcommon pixman wayland meson wayland-protocols)
if ! [[ -f "$filename" ]]; then
	wget -c https://codeberg.org/dnkl/$name/archive/$version.tar.gz -O $filename
fi
rm -rf "$name"
tar xf "$filename"
cd "$name"
meson build --buildtype=release --prefix=/usr
sed -i -e "691s|*ret|*ret=NULL|g" shm.c
ninja -C build
sudo ninja -C build install
cd ..
rm -rf "$name" "$filename"
echo "$version" > /var/lib/custom-packages/$name

