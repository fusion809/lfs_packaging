#!/bin/bash
set -e
name=flac
homepage="https://xiph.org/flac/"
description="Free Lossless Audio Codec"
repo=xiph/$name
version=$(gh_ver $repo)
depends=(gcc glibc libogg)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
options=(
	--prefix=/usr            \
    --disable-thorough-tests \
	--docdir=/usr/share/doc/$direname)
cmi "${options[@]}"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
