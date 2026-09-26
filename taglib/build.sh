#!/bin/bash
set -e
name=taglib
homepage="https://taglib.github.io/"
description="A Library for reading and editing the meta-data of several popular audio formats"
repo=$name/$name
version=$(gh_ver $repo)
depends=(gcc glibc zlib)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://taglib.org/releases/$filename"
unpk_enter "$filename" "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D BUILD_SHARED_LIBS=ON)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
