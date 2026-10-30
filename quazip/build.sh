#!/bin/bash
set -e
name=quazip
repo=stachenov/$name
homepage="https://stachenov.github.io/quazip/"
description="C++ wrapper for the zip/unzip C package."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr \
    -DQUAZIP_QT_MAJOR_VERSION=6)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
