#!/bin/bash
set -e
name=libsamplerate
repo=libsndfile/$name
homepage="https://libsndfile.github.io/libsamplerate/"
description="Audio sample rate conversion library."
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr
    -D CMAKE_BUILD_TYPE=None
    -D CMAKE_POLICY_VERSION_MINIMUM=3.5
    -D BUILD_SHARED_LIBS=ON
    -Wno-dev)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
