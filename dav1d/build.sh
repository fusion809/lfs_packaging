#!/bin/bash
set -e
name=dav1d
description="AV1 cross-platform decoder focused on speed and correctness"
homepage="https://code.videolan.org/videolan/dav1d"
repo=videolan/$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://code.videolan.org/videolan/dav1d/-/archive/$version/$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release --wrap-mode=nofallback
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
