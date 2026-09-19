#!/bin/bash
set -e
name=libxmlb
repo="hughsie/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(glib2 glibc libffi pcre2 systemd util-linux xz zlib zstd)
ghr_download "hughsie/libxmlb" "$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release -D gtkdoc=false
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
