#!/bin/bash
# BLFS book compiles it with configure, make and make install
# That method of installation leads to:
# libssh.cps
# libsshConfig.cmake
# libssh-config.cmake
# files being omitted from install
# cmake-based installation is required
set -e
name=libssh2
version=$(gh_ver "$name/$name")
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(cmake gcc glibc openssl zlib)
download_src "https://www.libssh2.org/download/$filename"
unpk_enter "$filename" "$direname"
gap_patches "$name"
cmake_options=(
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DBUILD_STATIC_LIBS=OFF \
	-DHIDE_SYMBOLS=OFF
)
cmaki "${cmake_options[@]}" 
cd ../..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
