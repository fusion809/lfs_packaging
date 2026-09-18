#!/bin/bash
set -e
name=geocode-glib
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(brotli e2fsprogs glib2 glibc json-glib keyutils libffi libidn2 libpsl libsoup libunistring mitkrb nghttp2 pcre2 sqlite systemd util-linux zlib)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(
	--prefix=/usr 
	--buildtype=release 
	-D enable-gtk-doc=false 
	-D soup2=false
)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
