#!/bin/bash
set -e
name=glslc
repo=google/shaderc
version=$(gh_ver $repo)
filename="shaderc-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(cmake glslang spirv-tools)
if ! [[ -f $filename ]]; then
	wget -c
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed '/build-version/d'   -i glslc/CMakeLists.txt            &&
sed '/third_party/d'     -i CMakeLists.txt                  &&
sed 's|SPIRV|glslang/&|' -i libshaderc_util/src/compiler.cc &&

echo "\"$version\"" > glslc/src/build-version.inc
mkdir -p build
cd build
cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D SHADERC_SKIP_TESTS=ON     \
      -G Ninja ..
ninja glslc/glslc -j$(nproc)
sudo install -vm755 glslc/glslc /usr/bin
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
