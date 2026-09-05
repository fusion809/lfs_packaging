#!/bin/bash
set -e
name=gstreamer
version=$(gfd_ver gstreamer/gstreamer)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(glib2)
if ! [[ -f $filename ]]; then
	wget -c https://gstreamer.freedesktop.org/src/$name/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
meson_options=(--prefix=/usr       \
      --buildtype=release \
      -D gst_debug=false)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
