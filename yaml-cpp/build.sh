#!/bin/bash
set -e
name=yaml-cpp
repo=jbeder/$name
homepage="https://github.com/jbeder/yaml-cpp"
description="YAML parser and emitter in C++."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$direname" "$filename"
direname=$name-$direname
unpk_enter "$filename" "$direname"
cmake_options=(-DCMAKE_BUILD_TYPE=None \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -Wno-dev \
    -DYAML_CPP_BUILD_TESTS=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DYAML_BUILD_SHARED_LIBS=ON)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
