#!/bin/bash
set -e
name=libunwind
homepage="https://www.nongnu.org/libunwind/"
description="Determine and manipulate the call-chain of a program"
repo=$name/$name
version=$(gh_ver $repo)
depends=(gcc glibc xz zlib)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
sed -i '/func.s/s/s//' tests/Gtest-nomalloc.c
cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
