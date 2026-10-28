#!/bin/bash
set -e
name=snappy
repo=google/$name
homepage="https://github.com/google/snappy"
description="Fast compressor/decompressor library."
version=$(gh_ver $repo)
depends=(glibc gcc llvm cmake gtest)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "$direname" "$filename"
unpk_enter "$filename" "$direname"
arch_patch "$name"
wget -c "https://gitlab.archlinux.org/archlinux/packaging/packages/snappy/-/raw/main/snappy.pc.in?ref_type=heads&inline=false" -O snapper.pc.in
cmake_options=(-D CMAKE_BUILD_TYPE=None \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -W no-dev \
    -DCMAKE_CXX_STANDARD=23 \
    -DBUILD_SHARED_LIBS=ON \
    -DSNAPPY_BUILD_BENCHMARKS=OFF
)
cmaki "${cmake_options[@]}" 
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
