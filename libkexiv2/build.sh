#!/bin/bash
set -e
name=libkexiv2
repo=KDE/$name
homepage="https://develop.kde.org/products/frameworks/"
description="Wrapper around exiv2 for KDE."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release         \
      -D BUILD_WITH_QT6=ON                \
      -D BUILD_TESTING=OFF                \
      -W no-author)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
