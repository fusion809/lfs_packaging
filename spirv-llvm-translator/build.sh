#!/bin/bash
set -e
name=spirv-llvm-translator
version=$(gh_ver KhronosGroup/SPIRV-LLVM-Translator)
blfs_depends=(llvm spirv-tools libxml2)
filename="SPIRV-LLVM-Translator-$version.tar.gz"
direname="${filename/.tar.gz/}"

if ! [[ -f $filename ]]; then
	wget -c https://github.com/KhronosGroup/SPIRV-LLVM-Translator/archive/refs/tags/v$version.tar.gz -O $filename
fi

rm -rf $direname
tar xf $filename
cd $direname
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D BUILD_SHARED_LIBS=ON -D CMAKE_SKIP_INSTALL_RPATH=ON -D LLVM_EXTERNAL_SPIRV_HEADERS_SOURCE_DIR=/usr -G Ninja
cd ../..
rm -rf $direname $filename
echo "$version" > /var/lib/custom-packages/$name
