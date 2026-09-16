#!/bin/bash
set -e
name=fcft
repo=dnkl/$name
version=$(cb_ver $repo)
depends=(fontconfig freetype2 meson ninja pixman)
direname="$name-$version"
filename="$name-$version.tar.gz"

if ! [[ -f "$filename" ]]; then
	wget -c --progress=bar:force https://codeberg.org/$repo/archive/$version.tar.gz -O $filename 
fi
tar xf "$filename"
cd "$name"
mni --buildtype=release --prefix=/usr
cd ../..
rm -rf "$name" "$filename"
echo "$version" | sudo tee /var/lib/custom-packages/$name
