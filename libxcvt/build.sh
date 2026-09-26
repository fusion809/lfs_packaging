#!/bin/bash
set -e
name=libxcvt
homepage="https://gitlab.freedesktop.org/xorg/lib/libxcvt"
description="library providing a standalone version of the X server implementation of the VESA CVT standard timing modelines generator"
version=$(xfd_ver $name | grep -oE "[0-9.]+")
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
