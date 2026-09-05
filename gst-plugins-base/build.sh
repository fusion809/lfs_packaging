#!/bin/bash
set -e
name=gst-plugins-base
version=$(gfd_ver gstreamer/gstreamer)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gstreamer alsa-lib cdparanoia glib2 iso-codes libgudev libjpeg-turbo libogg libpng libvorbis mesa pango wayland-protocols xorg-libs)
if ! [[ -f $filename ]]; then
	wget -c https://gstreamer.freedesktop.org/src/gst-plugins-bad/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
meson_options=(--prefix=/usr       \
      --buildtype=release \
      --wrap-mode=nodownload)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
