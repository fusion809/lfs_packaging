#!/bin/bash
set -e
name=fast_float
repo="fastfloat/fast_float"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(cmake)
gha_download "$repo" "v$version" "$filename" 
unpk_enter "$filename" "$direname"
cmake_options=(
      -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -G Ninja)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
