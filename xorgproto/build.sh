#!/bin/bash
set -e
name=xorgproto
homepage="https://xorg.freedesktop.org/"
description="combined X.Org X11 Protocol headers"
version=$(xfd_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
xfd_download "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr
sudo mv -v /usr/share/doc/$name{,-$version}
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
