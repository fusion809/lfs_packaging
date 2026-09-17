#!/bin/bash
set -e
name=spirv-llvm-translator
repo=KhronosGroup/SPIRV-LLVM-Translator
version=$(gh_ver $repo $name)
depends=(libxml2 llvm spirv-tools)
filename="SPIRV-LLVM-Translator-$version.tar.gz"
direname="${filename/.tar.gz/}"

gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D BUILD_SHARED_LIBS=ON -D CMAKE_SKIP_INSTALL_RPATH=ON -D LLVM_EXTERNAL_SPIRV_HEADERS_SOURCE_DIR=/usr -G Ninja
cd ../..
rm -rf $direname $filename
echo "$version" | sudo tee /var/lib/custom-packages/$name
