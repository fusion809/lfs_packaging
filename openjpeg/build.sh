#!/bin/bash
set -e
name=openjpeg
repo=uclouvain/$name
version=$(gh_ver $repo)
depends=(cmake glibc lcms2 libjpeg-turbo libpng libtiff libwebp xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
options=(-D CMAKE_BUILD_TYPE=Release  \
      -D CMAKE_INSTALL_PREFIX=/usr \
      -D BUILD_STATIC_LIBS=OFF)
cmaki "${options[@]}"
sudo cp -rv ../doc/man -T /usr/share/man
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
