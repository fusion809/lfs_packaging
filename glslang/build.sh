#!/bin/bash
set -e
name=glslang
repo=KhronosGroup/$name
version=$(gh_ver $repo)
depends=(gcc glibc)
blfs_depends=(spirv-tools)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/archive/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D ALLOW_EXTERNAL_SPIRV_TOOLS=ON \
      -D BUILD_SHARED_LIBS=ON          \
      -D GLSLANG_TESTS=ON              \
      -G Ninja)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
