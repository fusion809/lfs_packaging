#!/bin/bash
set -e
name=geocode-glib
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(brotli e2fsprogs glib2 glibc json-glib keyutils libffi libidn2 libpsl libunistring mitkrb nghttp2 pcre2 sqlite systemd util-linux zlib)
blfs_depends=(libsoup)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/$name/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr --buildtype=release -D enable-gtk-doc=false \
            -D soup2=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
