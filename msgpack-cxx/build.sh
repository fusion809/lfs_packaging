#!/bin/bash
set -e
name=msgpack-cxx
_name=msgpack-c
repo=msgpack/$_name
homepage="https://msgpack.org/"
description="An efficient object serialization library for C++."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="msgpack-c-cpp-$version"
gha_download "$repo" "cpp-$version" "$filename"
unpk_enter "$filename"
cmake_options=(-Wno-dev \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_BUILD_TYPE=None \
	-DMSGPACK_CXX17=ON \
	-DMSGPACK_BUILD_EXAMPLES=OFF \
	-DMSGPACK_BUILD_TESTS=OFF
)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
