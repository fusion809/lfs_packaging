#!/bin/bash
set -e
name=xcb-util-errors
version=$(xcb_ver $name)
depends=(glibc libXau libxcb libXdmcp)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
xfd_download "$name" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
