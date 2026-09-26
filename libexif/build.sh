#!/bin/bash
set -e
name=libexif
homepage="https://github.com/libexif/libexif"
description="Library to parse an EXIF file and read the data from those tags"
repo=$name/$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static --with-doc-dir=/usr/share/doc/$direname
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
