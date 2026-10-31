#!/bin/bash
set -e
name=opencolorio
_name=OpenColorIO
repo=AcademySoftwareFoundation/$_name
homepage="https://opencolorio.org/"
description="Colour framework for visual effects and animation."
version=$(gh_ver $repo)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(expat freeglut imath lcms2 gcc openexr minizip-ng pystring yaml-cpp)
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
CXXFLAGS+=" -ffat-lto-objects"
cmake_options=(-G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_SKIP_INSTALL_RPATH=YES \
    -Wno-dev)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
