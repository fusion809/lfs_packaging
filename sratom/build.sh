#!/bin/bash
set -e
name=sratom
repo=lv2/$name
homepage="https://drobilla.net/software/sratom.html"
description=""
version=$(gl_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(lv2 sord serd meson glibc)
download_src "https://download.drobilla.net/$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
