#!/bin/bash
set -e
name=pygobject
homepage="https://wiki.gnome.org/Projects/PyGObject"
description="Python bindings for the GObject class from GLib."
version=$(gn_ver pygobject)
majVer=$(echo $version | sed 's/.[0-9]$//g')
depends=(brotli bzip2 cairo expat fontconfig freetype glib2 glibc libffi libpng libx11 libxau libxcb libxdmcp libxext libxrender pcre2 pixman pycairo zlib)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gn_download "$filename"

unpk_enter "$filename" "$direname"
options=(--prefix=/usr \
	--buildtype=release)
mni "${options[@]}"
cd ../..
rm -rf $direname $filename
echo "$version" | sudo tee /var/lib/custom-packages/$name
