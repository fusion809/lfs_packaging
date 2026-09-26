#!/bin/bash
set -e
name=tinysparql
homepage="https://tinysparql.org/"
description="Low-footprint RDF triple store with SPARQL 1.1 interface"
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(avahi brotli dbus e2fsprogs gcc glib2 glibc icu json-glib keyutils libffi libidn2 libpsl libsoup libunistring libxml2 mitkrb nghttp2 pcre2 sqlite systemd util-linux zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(--prefix=/usr --buildtype=release -D man=false        \
            -D tests=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
