#!/bin/bash
set -e
name=xinit
version=$(xfd_ver $name)
depends=(glibc libX11 libxau libxcb libXdmcp)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
xfd_download "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
cmi --prefix=/usr --with-xinitdir=/etc/X11/app-defaults
cd ../
sudo ldconfig
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
