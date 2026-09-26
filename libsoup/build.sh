#!/bin/bash
set -e
name=libsoup
homepage="HTTP client/server library for GNOME"
description="HTTP client/server library for GNOME"
version=$(gn_ver $name)
depends=(brotli e2fsprogs glib2 glibc keyutils libffi libidn2 libpsl libunistring mitkrb nghttp2 pcre2 sqlite systemd util-linux zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
gap_patches libsoup3
options=(--prefix=/usr          \
            --buildtype=release    \
	    --wrap-mode=nofallback)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
