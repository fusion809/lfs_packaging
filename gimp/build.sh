#!/bin/bash
set -e
name=gimp
repo=GNOME/$name
homepage="https://gimp.org"
description="GNU Image Manipulation Program."
depends=(libmypaint mypaint-brushes appstream gegl gexiv2 glib-networking gtk3 harfbuzz librsvg tiff libxml2 lcms2 poppler graphviz ghostscript iso-codes libgudev xdg-utils)
version=$(gh_ver $repo)
majMinVer=$(echo $version | cut -d '.' -f1-2)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://download.gimp.org/gimp/v$majMinVer/$filename"
unpk_enter "$filename" "$direname"
sudo su -c "rm -rf /usr/{lib,share}/gimp/3.0 &&
rm -f  /usr/share/gir-1.0/Gimp-3.0.gir &&
rm -f  /usr/lib/girepository-1.0/Gimp-3.0.typelib &&
rm -f  /usr/lib/libgimp*-3.0.so*"
patch -Np1 -i build/macos/patches/0001-build-macos-Do-not-require-gexiv2-0.14-on-homebrew.patch
mni --prefix=/usr --buildtype=release -D headless-tests=disabled
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
