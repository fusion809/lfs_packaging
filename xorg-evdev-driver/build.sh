#!/bin/bash
set -e
name=xorg-evdev-driver
version=$(xfd_ver xf86-input-evdev)
depends=(glibc libevdev mtdev systemd)
filename="xf86-input-evdev-$version.tar.xz"
direname="${filename/.tar.*/}"
xfd_download "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
