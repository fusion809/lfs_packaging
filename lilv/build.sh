#!/bin/bash
set -e
name=lilv
repo=lv2/$name
homepage="https://gitlab.com/lv2/lilv"
description="C library interface for the LV2 plugin standard."
version=$(gl_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(serd sord lv2 libsndfile python sratom swig)
download_src "https://download.drobilla.net/$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
