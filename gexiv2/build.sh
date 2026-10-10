#!/bin/bash
set -e
name=gexiv2
repo=GNOME/$name
homepage="https://wiki.gnome.org/Projects/gexiv2"
description="gexiv2 is a GObject-based wrapper around the Exiv2 library."
version=$(gh_ver $repo)
depends=(brotli curl cyrus-sasl exiv2 expat gcc glib2 glibc inih libffi libidn2 libpsl libselinux libunistring nghttp2 openldap openssl pcre2 systemd util-linux zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
