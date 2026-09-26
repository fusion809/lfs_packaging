#!/bin/bash
set -e
name=libpsl
homepage="https://github.com/rockdaboot/libpsl"
description="Public Suffix List library"
repo="rockdaboot/libpsl"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(glibc libidn2 libidn2 libunistring libunistring)
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
