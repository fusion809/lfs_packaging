#!/bin/bash
set -e
name=zlib-ng
repo=$name/$name
homepage="https://github.com/zlib-ng/zlib-ng"
description="zlib replacement with next-generation optimizations."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-G Ninja
    -DCMAKE_BUILD_TYPE=None
    -DCMAKE_INSTALL_PREFIX=/usr
    -DCMAKE_INSTALL_LIBDIR=lib
    -Wno-dev
    -DWITH_GTEST=OFF
    -DBUILD_SHARED_LIBS=ON
)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
