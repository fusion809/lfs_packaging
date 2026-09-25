#!/bin/bash
set -e
name=gstreamer
homepage="https://gstreamer.freedesktop.org"
version=$(gfd_ver gstreamer/gstreamer)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(glib2)
download_src "https://gstreamer.freedesktop.org/src/$name/$filename"
unpk_enter "$filename" "$direname"
meson_options=(--prefix=/usr       \
      --buildtype=release \
      -D gst_debug=false)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
