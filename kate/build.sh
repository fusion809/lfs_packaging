#!/bin/bash
set -e
name=kate
homepage="https://apps.kde.org/kate/"
description="Advanced text editor"
version=$(kap_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(frameworks6)
kde_download "app" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(
      -D CMAKE_INSTALL_PREFIX=/usr  \
      -D CMAKE_BUILD_TYPE=Release          \
      -D BUILD_TESTING=OFF                 \
      -W no-author)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
