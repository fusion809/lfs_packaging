#!/bin/bash
set -e
name=libxcvt
version=$(xfd_ver $name)
depends=(glibc)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
xfd_download "$filename"
unpk_enter "$filename" "$direname"
options=(--prefix=/usr --buildtype=release)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
