#!/bin/bash
set -e
name=libtool
version=$(gnu_ver $name)
depends=(glibc)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
gnu_download "$name" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
sudo rm -fv /usr/lib/libltdl.a
cd ..
echo "$version" | sudo tee /var/lib/custom-packages/$name
