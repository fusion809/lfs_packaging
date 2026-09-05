#!/bin/bash
set -e
name=gdk-pixbuf
version=$(gn_ver $name)
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
