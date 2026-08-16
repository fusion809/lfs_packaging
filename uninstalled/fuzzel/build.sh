#!/bin/bash
set -e
name=fuzzel
repo=dnkl/$name
version=$(cb_ver $repo)
direname="$name-$version"
filename="$direname.tar.gz"
depends=(scdoc fcft)
blfs_depends=(fontconfig libpng libxkbcommon pixman wayland meson wayland-protocols)
if ! [[ -f "$filename" ]]; then
	wget -c https://codeberg.org/$repo/archive/$version.tar.gz -O $filename
fi
rm -rf "$name"
tar xf "$filename"
cd "$name"
sed -i -e "691s|*ret|*ret=NULL|g" shm.c
mni --buildtype=release --prefix=/usr
cd ../..
rm -rf "$name" "$filename"
echo "$version" > /var/lib/custom-packages/$name

