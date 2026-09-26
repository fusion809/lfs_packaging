#!/bin/bash
set -e
_name=libXau
name=$(echo $_name | tr '[:upper:]' '[:lower:]')
homepage="https://xorg.freedesktop.org/"
description="X11 authorisation library"
version=$(xfd_ver $_name)
depends=(glibc)
filename="$_name-$version.tar.xz"
direname="${filename/.tar.*/}"
xfd_download "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
