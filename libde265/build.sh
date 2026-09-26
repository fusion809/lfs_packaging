#!/bin/bash
set -e
name=libde265
homepage="https://github.com/strukturag/libde265"
description="Open h.265 video codec implementation"
repo=strukturag/$name
version=$(gh_ver $repo)
depends=(cmake)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr \
	-D CMAKE_BUILD_TYPE=Release)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
