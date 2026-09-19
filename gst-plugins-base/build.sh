#!/bin/bash
set -e
name=gst-plugins-base
version=$(gfd_ver gstreamer/gstreamer)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(alsa-lib cdparanoia glib2 gstreamer iso-codes libgudev libjpeg-turbo libogg libpng libvorbis mesa pango wayland-protocols xorg-libs)
download_src "https://gstreamer.freedesktop.org/src/$name/$filename"
unpk_enter "$filename" "$direname"
meson_options=(--prefix=/usr       \
      --buildtype=release \
      --wrap-mode=nodownload)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
