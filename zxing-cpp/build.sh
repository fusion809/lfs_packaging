#!/bin/bash
set -e
name=zxing-cpp
homepage="https://github.com/zxing-cpp/zxing-cpp"
description="An open-source, multi-format linear/matrix barcode image processing library implemented in C++"
repo=$name/$name
version=$(gh_ver $repo)
depends=(gcc glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr \
      -D ZXING_C_API=OFF           \
      -D ZXING_EXAMPLES=OFF        \
      -D ZXING_WRITERS=BOTH        \
      -W no-author)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
