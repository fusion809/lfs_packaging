#!/bin/bash
set -e
name=gdk-pixbuf
if [[ $(pkgver glycin) -ge 2.2  ]] ; then
	version=$(gn_ver $name)
else
	version=2.44.7 
fi
# 2.44.8 and later require 2.2.x versions of glycin which are pre-release
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(glib2 shared-mime-info docutils glycin)
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/gdk-pixbuf/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
meson_options=(--prefix=/usr           \
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
