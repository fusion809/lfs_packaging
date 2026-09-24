#!/bin/bash
set -e
name=libxcb
version=$(xfd_ver $name | grep -oE "[0-9.]+")
depends=(glibc libxau libXdmcp xcb-proto)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
xfd_download "$filename"
unpk_enter "$filename" "$direname"
./configure --prefix=/usr --without-doxygen --docdir=/usr/share/doc/$direname
LC_ALL=en_US.UTF-8 maki
sudo su -c "chown -Rv root:root /usr/share/doc/$direname"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
