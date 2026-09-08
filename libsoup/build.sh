#!/bin/bash
set -e
name=libsoup
version=$(gn_ver $name)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
depends=(brotli e2fsprogs glib2 glibc keyutils libffi libidn2 libpsl libunistring mitkrb nghttp2 pcre2 sqlite systemd util-linux zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/libsoup/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
gap_patches libsoup3
options=(--prefix=/usr          \
            --buildtype=release    \
	    --wrap-mode=nofallback)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
