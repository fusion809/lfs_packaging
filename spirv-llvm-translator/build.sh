#!/bin/bash
set -e
name=spirv-llvm-translator
homepage="https://www.khronos.org/spirv/"
description="LLVM <-> SPIR-V converter for compilers targeting SPIR-V."
repo=KhronosGroup/SPIRV-LLVM-Translator
version=$(gh_ver $repo $name)
depends=(gcc glibc icu libffi libxml2 llvm spirv-tools zlib zstd)
filename="SPIRV-LLVM-Translator-$version.tar.gz"
direname="${filename/.tar.gz/}"

gha_download "$repo" "v$version" "$filename"
package_dir=$PWD
build_dir=$(mktemp -d "/tmp/${name}.XXXXXX")
tar -xf "$filename" --strip-components=1 -C "$build_dir"
cd "$build_dir"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D BUILD_SHARED_LIBS=ON -D CMAKE_SKIP_INSTALL_RPATH=ON -G Ninja
cd "$package_dir"
rm -rf "$build_dir" "$filename"
echo "$version" | sudo tee /var/lib/custom-packages/$name
