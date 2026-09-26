#!/bin/bash
set -e
name=libqrencode
description="C library for encoding data in a QR Code symbol."
homepage="https://fukuchi.org/works/qrencode/"
repo=fukuchi/$name
version=$(gh_ver $repo)
depends=(glibc libpng zlib)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
