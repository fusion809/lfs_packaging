#!/bin/bash
set -e
name=spirv-headers
_name=SPIRV-Headers-vulkan-sdk
repo=KhronosGroup/SPIRV-Headers
version=$(gh_ver $repo $name)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(cmake)
gha_download "$repo" "vulkan-sdk-$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -G Ninja
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
