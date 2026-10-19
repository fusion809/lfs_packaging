#!/bin/bash
set -e
name=utf8cpp
_name=utfcpp
repo=nemtrif/utfcpp
homepage="https://github.com/nemtrif/utfcpp"
description="UTF-8 with C++ in a portable way."
version=$(gh_ver $repo)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -DCMAKE_BUILD_TYPE=None -DCMAKE_INSTALL_PREFIX=/usr
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
