#!/bin/bash
set -e
name=gst-plugins-bad
version=$(gfd_ver gstreamer/gstreamer)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gst-plugins-base libaom libdvdnav libdvdread libva soundtouch svt-av1)
download_src "https://gstreamer.freedesktop.org/src/gst-plugins-bad/$filename"
unpk_enter "$filename" "$direname"
meson_options=(--prefix=/usr       \
      --buildtype=release \
      -D gpl=enabled)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
