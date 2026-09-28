#!/bin/bash
set -e
name=gjs
homepage="https://gitlab.gnome.org/GNOME/gjs"
description="Javascript Bindings for GNOME."
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 cairo expat fontconfig freetype gcc glib2 glibc icu libffi libpng libx11 libxau libxcb libxdmcp libxext libxrender ncurses pcre2 pixman readline systemd util-linux zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(
	--prefix=/usr \
	--buildtype=release \
	--wrap-mode=nofallback)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
