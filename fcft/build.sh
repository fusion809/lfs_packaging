#!/bin/bash
set -e
name=fcft
homepage="https://codeberg.org/dnkl/fcft"
description="Simple library for font loading and glyph rasterization"
repo=dnkl/$name
version=$(cb_ver $repo)
depends=(fontconfig freetype2 meson ninja pixman)
direname="$name-$version"
filename="$name-$version.tar.gz"

download_src "https://codeberg.org/$repo/archive/$version.tar.gz" "$filename"
unpk_enter "$filename" "$name"
mni --buildtype=release --prefix=/usr
cd ../..
rm -rf "$name" "$filename"
echo "$version" | sudo tee /var/lib/custom-packages/$name
