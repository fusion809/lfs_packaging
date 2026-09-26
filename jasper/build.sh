#!/bin/bash
set -e
name=jasper
homepage="https://www.ece.uvic.ca/~frodo/jasper/"
description="Software-based implementation of the codec specified in the emerging JPEG-2000 Part-1 standard"
repo=$name-software/$name
version=$(gh_ver $repo)
depends=(gcc glibc libaom libde265 libheif libjpeg-turbo libwebp numactl x264 x265)
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
