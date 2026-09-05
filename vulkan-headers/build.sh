#!/bin/bash
set -e
name=vulkan-headers
repo=KhronosGroup/Vulkan-Headers
version=$(gh_ver $repo)
filename="Vulkan-Headers-vulkan-sdk-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(cmake)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/archive/vulkan-sdk-$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -G Ninja
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
