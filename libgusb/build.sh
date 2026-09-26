#!/bin/bash
set -e
# Variable declaration
name=libgusb
homepage="https://github.com/hughsie/libgusb"
description="GObject wrapper for libusb1"
repo=hughsie/libgusb
version=$(gh_ver "$repo")
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
depends=(glib2 glib2 glibc hwdata json-glib libffi libusb pcre2 systemd util-linux vala webkitgtk zlib)
# Fetch source and unpack it
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
meson_options=(
	--prefix=/usr       \
    --buildtype=release \
	-D docs=false
)
mni "${meson_options[@]}"
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
