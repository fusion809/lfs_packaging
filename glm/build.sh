#!/bin/bash
set -e
name=glm
repo=g-truc/$name
homepage="http://glm.g-truc.net"
description="C++ 3D software mathematics library."
version=$(gh_ver $repo)
depends=(cmake ninja)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-G Ninja \
	-DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_INSTALL_DATAROOTDIR=/usr/lib/cmake \
    -W no-dev)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
