#!/bin/bash
set -e
name=cairomm
repo=cairo/cairomm
homepage="https://gitlab.freedesktop.org/cairo/cairomm"
description="Provides a C++ interface to Pango."
version=$(gfl_ver $repo)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(glib2 libsigcpp2)
gfd_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
