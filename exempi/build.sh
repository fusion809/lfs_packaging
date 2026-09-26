#!/bin/bash
set -e
name=exempi
homepage="https://libopenraw.freedesktop.org/exempi/"
description="Library to parse XMP metadata"
repo=libopenraw/$name
version=$(gfd_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(boost)
download_src "https://libopenraw.freedesktop.org/download/$filename"
unpk_enter "$filename" "$direname"
sed -i -r '/^\s?testadobesdk/d' exempi/Makefile.am &&
sudo autoreconf -fiv
sudo chown $USER -R .
cmi --prefix=/usr --disable-static
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
