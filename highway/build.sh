#!/bin/bash
set -e
name=highway
homepage="https://github.com/google/highway/"
description="A C++ library that provides portable SIMD/vector intrinsics"
repo=google/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(cmake)
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D CMAKE_BUILD_TYPE=Release \
	-D BUILD_TESTING=OFF \
	-D BUILD_SHARED_LIBS=ON \
	-G Ninja)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
