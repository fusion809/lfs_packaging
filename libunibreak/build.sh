#!/bin/bash
set -e
name=libunibreak
repo=adah1972/$name
homepage="https://github.com/adah1972/libunibreak/"
description="Implementation of line-breaking algorithm."
version=$(gh_ver $repo)
filename="$name-${name}_${version//./_}.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$name_${version//./_}" "$filename"
unpk_enter "$filename" "$direname"
./bootstrap
cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
