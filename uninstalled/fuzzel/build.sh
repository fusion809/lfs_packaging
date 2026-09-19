#!/bin/bash
set -e
name=fuzzel
repo=dnkl/$name
version=$(cb_ver $repo)
direname="$name-$version"
filename="$direname.tar.gz"
depends=(fcft fontconfig libpng libxkbcommon meson pixman scdoc wayland wayland-protocols)
download_src "https://codeberg.org/$repo/archive/$version.tar.gz" "$filename"
unpk_enter "$filename" "$name"
sed -i -e "691s|*ret|*ret=NULL|g" shm.c
mni --buildtype=release --prefix=/usr
cd ../..
rm -rf "$name" "$filename"
echo "$version" | sudo tee /var/lib/custom-packages/$name

