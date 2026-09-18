#!/bin/bash
set -e
name=gdk-pixbuf
if [[ $(pkgver glycin) -ge 2.2  ]] ; then
	version=$(gn_ver $name)
else
	version=2.44.7 
fi
# 2.44.8 and later require 2.2.x versions of glycin which are pre-release
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(docutils glib2 glycin shared-mime-info)
gn_download "$filename"
unpk_enter "$filename" "$direname"
meson_options=(
      --prefix=/usr           \
      --buildtype=release     \
      -D png=disabled         \
      -D gif=disabled         \
      -D jpeg=disabled        \
      -D tiff=disabled        \
      -D thumbnailer=disabled \
      --wrap-mode=nofallback  \
      $(pkgconf glycin-2 || echo -D glycin=disabled))
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
