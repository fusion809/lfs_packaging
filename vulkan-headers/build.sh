#!/bin/bash
set -e
name=vulkan-headers
repo=KhronosGroup/Vulkan-Headers
version=$(gh_ver $repo)
filename="Vulkan-Headers-vulkan-sdk-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(cmake)
gha_download "$repo" "vulkan-sdk-$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -G Ninja
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
