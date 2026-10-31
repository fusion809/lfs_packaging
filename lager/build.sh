#!/bin/bash
set -e
name=lager
repo=$name/$name
homepage="https://sinusoid.es/lager"
description="C++ library for value-oriented design."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr \
    -Dlager_BUILD_EXAMPLES=OFF \
    -Dlager_BUILD_TESTS=OFF
)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
