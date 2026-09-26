#!/bin/bash
set -e
name=nghttp2
homepage="Client, server and proxy programs from the nghttp2 library"
description="Client, server and proxy programs from the nghttp2 library"
repo="$name/$name"
version=$(gh_ver $repo)
majVer=$(echo $version | sed 's/.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gcc glibc hdf5 libaec libxml2 zlib)
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static --enable-lib-only --docdir=/usr/share/doc/$direname
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
