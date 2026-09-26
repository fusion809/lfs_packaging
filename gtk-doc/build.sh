#!/bin/bash
set -e
name=gtk-doc
homepage="https://gitlab.gnome.org/GNOME/gtk-doc"
description="Documentation tool for public library API"
version=$(gn_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(--prefix=/usr       \
      --buildtype=release \
      -D tests=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
