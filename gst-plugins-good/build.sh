#!/bin/bash
set -e
name=gst-plugins-good
version=$(gfd_ver gstreamer/gstreamer)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gst-plugins-base libaom libdvdnav libdvdread libva soundtouch svt-av1)
download_src "https://gstreamer.freedesktop.org/src/gst-plugins-good/$filename"
unpk_enter "$filename" "$direname"
meson_options=(--prefix=/usr       \
	--buildtype=release)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
