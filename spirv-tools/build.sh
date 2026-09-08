#!/bin/bash
set -e
name=spirv-tools
repo=KhronosGroup/SPIRV-Tools
version=$(gh_ver $repo)
depends=(gcc glibc)
filename="SPIRV-Tools-vulkan-sdk-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/archive/vulkan-sdk-$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr     \
      -D CMAKE_BUILD_TYPE=Release      \
      -D SPIRV_WERROR=OFF              \
      -D BUILD_SHARED_LIBS=ON          \
      -D SPIRV_TOOLS_BUILD_STATIC=OFF  \
      -D SPIRV-Headers_SOURCE_DIR=/usr \
      -G Ninja)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
