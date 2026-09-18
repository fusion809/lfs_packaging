#!/bin/bash
set -e
name=c-ares
repo=$name/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(cmake)
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
