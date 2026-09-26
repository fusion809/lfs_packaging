#!/bin/bash
set -e
name=libei
homepage="https://libinput.pages.freedesktop.org/libei/"
description="Library for Emulated Input"
repo=libinput/$name
version=$(gfd_ver $repo)
depends=(glibc libevdev libxkbcommon systemd)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
gfd_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release -D tests=disabled
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
