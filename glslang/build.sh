#!/bin/bash
set -e
name=glslang
homepage="https://github.com/KhronosGroup/glslang"
description="OpenGL and OpenGL ES shader front end and validator"
repo=KhronosGroup/$name
version=$(gh_ver $repo)
depends=(gcc glibc spirv-tools)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(
      -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release \
      -D ALLOW_EXTERNAL_SPIRV_TOOLS=ON \
      -D BUILD_SHARED_LIBS=ON          \
      -D GLSLANG_TESTS=ON              \
      -G Ninja)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
