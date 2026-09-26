#!/bin/bash
set -e
name=jansson
homepage="https://www.digip.org/jansson/"
description="C library for encoding, decoding and manipulating JSON data"
repo="akheron/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
