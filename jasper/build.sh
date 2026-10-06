#!/bin/bash
set -e
name=jasper
homepage="https://www.ece.uvic.ca/~frodo/jasper/"
description="Implementation of the JPEG-2000 Part-1 standard codec."
repo=$name-software/$name
version=$(gh_ver $repo)
depends=(freeglut gcc glibc glu libaom libde265 libglvnd libheif libice libjpeg-turbo libsm libwebp libx11 libxau libxcb libxdmcp libxext libxi libxmu libxrandr libxrender libxt libxxf86vm numactl util-linux x264 x265)
filename="$name-version-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "version-$version" "$filename"
unpk_enter "$filename" "$direname"
options=(
      -D CMAKE_INSTALL_PREFIX=/usr    \
      -D CMAKE_BUILD_TYPE=Release     \
      -D CMAKE_SKIP_INSTALL_RPATH=ON  \
      -D JAS_ENABLE_DOC=NO            \
      -D ALLOW_IN_SOURCE_BUILD=YES    \
      -D CMAKE_INSTALL_DOCDIR=/usr/share/doc/$direname)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
