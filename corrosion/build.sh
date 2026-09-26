#!/bin/bash
set -e
name=corrosion
homepage="https://github.com/corrosion-rs/corrosion"
description="Tool for integrating Rust into an existing CMake project"
repo=$name-rs/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
export PATH=$PATH:/opt/rustc/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rustc/lib
sed -i 's/list(APPEND CMAKE_MODULE_PATH/list(PREPEND CMAKE_MODULE_PATH/' cmake/CorrosionConfig.cmake.in
cmake_options=(
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D CMAKE_BUILD_TYPE=Release \
	-D Rust_CARGO_TARGET=x86_64-unknown-linux-gnu \
	-D CMAKE_INSTALL_LIBEXECDIR=lib \
	-D CORROSION_BUILD_TESTS=OFF \
	-W no-author
)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
