#!/bin/bash
set -e
name=protobuf
homepage="https://protobuf.dev"
repo="protocolbuffers/$name"
version=$(gh_ver $repo)
depends=(abseil-cpp gcc glibc zlib)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr      \
      -D CMAKE_BUILD_TYPE=Release       \
      -D CMAKE_SKIP_INSTALL_RPATH=ON    \
      -D protobuf_BUILD_TESTS=OFF       \
      -D protobuf_BUILD_SHARED_LIBS=ON  \
      -G Ninja)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
