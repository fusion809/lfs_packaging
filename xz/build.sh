#!/bin/bash
set -e
name=xz
description="Library and command line tools for XZ and LZMA compressed files"
homepage="https://tukaani.org/xz/"
repo=tukaani-project/$name
version=$(gh_ver $repo)
depends=(coreutils gcc glibc gzip make tar xz)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static --docdir=/usr/share/doc/$direname
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
