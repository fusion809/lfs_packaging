#!/bin/bash
set -e
name=vulkan-loader
repo=KhronosGroup/Vulkan-Loader
version=$(gh_ver $repo)
filename="Vulkan-Loader-vulkan-sdk-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(cmake mesa vulkan-headers wayland xorg-libs)
gha_download "$repo" "vulkan-sdk-$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(
      -D CMAKE_INSTALL_PREFIX=/usr   \
      -D CMAKE_BUILD_TYPE=Release    \
      -D CMAKE_SKIP_INSTALL_RPATH=ON \
      -G Ninja
)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
