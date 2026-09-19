#!/bin/bash
set -e
name=librest
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(brotli e2fsprogs gcc glib2 glibc icu json-glib keyutils libffi libidn2 libpsl libsoup libunistring libxml2 mitkrb nghttp2 pcre2 sqlite systemd util-linux zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://download.gnome.org/sources/$name/$majVer/$filename
fi
unpk_enter "$filename" "$direname"
options=(--prefix=/usr --buildtype=release -D examples=false   \
            -D gtk_doc=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
