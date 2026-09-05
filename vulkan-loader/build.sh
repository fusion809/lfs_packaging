#!/bin/bash
set -e
name=vulkan-loader
repo=KhronosGroup/Vulkan-Loader
version=$(gh_ver $repo)
filename="Vulkan-Loader-vulkan-sdk-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(cmake vulkan-headers xorg-libs wayland mesa)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/KhronosGroup/Vulkan-Loader/archive/vulkan-sdk-$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr   \
      -D CMAKE_BUILD_TYPE=Release    \
      -D CMAKE_SKIP_INSTALL_RPATH=ON \
      -G Ninja)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
