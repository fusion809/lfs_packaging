#!/bin/bash
set -e
name=libzip
repo=nih-at/$name
homepage="https://libzip.org/"
description="C library for reading, creating and modifying zip archives."
version=$(gh_ver $repo)
depends=(bzip2 glibc openssl xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -DCMAKE_INSTALL_PREFIX=/usr
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
