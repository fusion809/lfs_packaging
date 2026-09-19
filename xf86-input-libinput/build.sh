#!/bin/bash
set -e
name=xf86-input-libinput
version=$(xfd_ver $name)
depends=(glibc libevdev libinput lua mtdev systemd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
xfd_download "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
