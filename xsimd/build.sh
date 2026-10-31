#!/bin/bash
set -e
name=xsimd
repo=QuantStack/$name
homepage="https://github.com/QuantStack/xsimd"
description="QuantStack tools library with multidimensional arrays."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(cmake gtest)
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -DCMAKE_INSTALL_PREFIX=/usr
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
