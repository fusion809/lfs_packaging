#!/bin/bash
set -e
name=blosc
_name=c-blosc
repo=Blosc/$name
homepage="https://www.blosc.org"
description="A blocking, shuffling and loss-less compression library."
depends=(glibc lz4 snappy zlib zstd cmake)
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(
    -D CMAKE_INSTALL_PREFIX=/usr
    -D BUILD_STATIC=OFF
    -D DEACTIVATE_SNAPPY=OFF
    -D PREFER_EXTERNAL_LZ4=ON
    -D PREFER_EXTERNAL_ZLIB=ON
    -D PREFER_EXTERNAL_ZSTD=ON
    -D CMAKE_C_STANDARD=17
  )
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
