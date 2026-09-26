#!/bin/bash
set -e
name=geoclue
description="Modular geoinformation service built on the D-Bus messaging system"
homepage="https://gitlab.freedesktop.org/geoclue/geoclue/-/wikis/home"
repo=$name/$name
version=$(gfd_ver $repo)
depends=(brotli bzip2 e2fsprogs expat fontconfig freetype gcc gdk-pixbuf glib2 glibc glycin json-glib keyutils lcms2 libffi libidn2 libnotify libpng libpsl libseccomp libsoup libunistring mitkrb modemmanager nghttp2 pcre2 sqlite systemd util-linux zlib)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
gfd_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
options=(
    --prefix=/usr        \
    --buildtype=release  \
    -D gtk-doc=false     \
	-D nmea-source=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
