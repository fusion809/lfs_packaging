#!/bin/bash
set -e
name=kseexpr
repo=KDE/$name
homepage="https://krita.org"
description="Embeddable expression evaluation engine."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(glibc ki18n gcc qt6 extra-cmake-modules)
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr \
    -DBUILD_DEMOS=OFF \
    -DBUILD_TESTS=OFF)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
