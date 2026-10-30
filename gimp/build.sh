#!/bin/bash
set -e
# Serialize builds of this package: unpk_enter removes the existing source
# directory before extracting, so overlapping autobuild runs can delete files
# underneath an active Meson/Ninja build.
exec 9>/tmp/autobuild-gimp.lock
flock 9

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
if [[ -f /var/lib/custom-packages/$name ]]; then
	sudo su -c "rm -rf /usr/{lib,share}/gimp/3.0 &&
				rm -rf  /usr/share/gir-1.0/Gimp-3.0.gir &&
			    rm -rf  /usr/lib/girepository-1.0/Gimp-3.0.typelib &&
				rm -rf  /usr/lib/libgimp*-3.0.so*"
fi
patch -Np1 -i build/macos/patches/0001-build-macos-Do-not-require-gexiv2-0.14-on-homebrew.patch
mni --prefix=/usr --buildtype=release -D headless-tests=disabled
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
