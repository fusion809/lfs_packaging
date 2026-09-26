#!/bin/bash
set -e
name=simdutf
homepage="https://simdutf.github.io/simdutf/"
description="Unicode routines (UTF8, UTF16, UTF32) and Base64"
repo="$name/$name"
version=$(gh_ver $repo)
depends=(cmake gcc glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(
      -D CMAKE_INSTALL_PREFIX=/usr  \
      -D CMAKE_BUILD_TYPE=Release   \
      -D BUILD_SHARED_LIBS=ON       \
      -G Ninja
)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
