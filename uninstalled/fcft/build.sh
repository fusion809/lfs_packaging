#!/bin/bash
set -e
name=fcft
repo=dnkl/$name
version=$(cb_ver $repo)
lfs_depends=(meson pixman ninja)
blfs_depends=(freetype2 fontconfig)
direname="$name-$version"
filename="$name-$version.tar.gz"

if ! [[ -f "$filename" ]]; then
	wget -c https://codeberg.org/$repo/archive/$version.tar.gz -O $filename 
fi
tar xf "$filename"
cd "$name"
mni --buildtype=release --prefix=/usr
cd ../..
rm -rf "$name" "$filename"
echo "$version" > /var/lib/custom-packages/$name
