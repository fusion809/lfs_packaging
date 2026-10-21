#!/bin/bash
set -e
name=primesieve
repo=kimwalisch/$name
homepage="https://github.com/kimwalisch/primesieve"
description="Fast prime number generator."
version=$(gh_ver $repo)
depends=(gcc gmp libx11 libxau libxcb libxdmcp ncurses readline sagemath ssw)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr \
    -DBUILD_STATIC_LIBS=OFF)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
