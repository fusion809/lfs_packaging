#!/bin/bash
set -e
name=geoclue
repo=$name/$name
version=$(gfd_ver $repo)
depends=(brotli bzip2 e2fsprogs expat fontconfig freetype gcc gdk-pixbuf glib2 glibc glycin json-glib keyutils lcms2 libffi libidn2 libnotify libpng libpsl libseccomp libsoup libunistring mitkrb nghttp2 pcre2 sqlite systemd util-linux zlib)
blfs_depends=(modemmanager)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://gitlab.freedesktop.org/geoclue/geoclue/-/archive/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr        \
            --buildtype=release  \
            -D gtk-doc=false     \
	    -D nmea-source=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
