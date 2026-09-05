#!/bin/bash
set -e
name=gst-plugins-bad
version=$(gfd_ver gstreamer/gstreamer)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gst-plugins-base libaom libdvdread libdvdnav libva svt-av1 soundtouch)
if ! [[ -f $filename ]]; then
	wget -c https://gstreamer.freedesktop.org/src/gst-plugins-bad/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
meson_options=(--prefix=/usr       \
      --buildtype=release \
      -D gpl=enabled)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
