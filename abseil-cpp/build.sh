#!/bin/bash
set -e
name=abseil-cpp
homepage="https://abseil.io"
description="Collection of C++ library code designed to augment the C++ standard library"
repo=abseil/abseil-cpp
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(cmake gcc glibc)
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr   \
      -D CMAKE_BUILD_TYPE=Release    \
      -D CMAKE_SKIP_INSTALL_RPATH=ON \
      -D ABSL_PROPAGATE_CXX_STD=ON   \
      -D BUILD_SHARED_LIBS=ON        \
      -G Ninja)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
