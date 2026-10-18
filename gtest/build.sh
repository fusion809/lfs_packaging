#!/bin/bash
set -e
name=gtest
_name=googletest
repo=google/$_name
homepage="https://github.com/google/googletest"
description="C++ testing utility."
version=$(gh_ver $repo)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=None \
    -Wno-dev \
    -DBUILD_SHARED_LIBS=ON \
    -Dgtest_build_tests=ON \
    -DGOOGLETEST_VERSION=$version
)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
