#!/bin/bash
set -e
name=gst-plugins-base
homepage="https://gstreamer.freedesktop.org/"
description="Multimedia graph framework - base plugins."
version=$(gfd_ver gstreamer/gstreamer)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(alsa-lib brotli bzip2 cairo cdparanoia elfutils expat fontconfig freetype fribidi gcc glib2 glibc graphene graphite2 gstreamer harfbuzz iso-codes libdrm libffi libglvnd libgudev libjpeg-turbo libogg libpng libunwind libvorbis libx11 libxau libxcb libxdmcp libxext libxi libxrender libxv mesa opus orc pango pcre2 pixman systemd util-linux wayland wayland-protocols xorg-libs xz zlib zstd)
download_src "https://gstreamer.freedesktop.org/src/$name/$filename"
unpk_enter "$filename" "$direname"
meson_options=(--prefix=/usr       \
      --buildtype=release \
      --wrap-mode=nodownload)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
