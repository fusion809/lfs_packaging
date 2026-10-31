#!/bin/bash
set -e
name=libunibreak
repo=adah1972/$name
homepage="https://github.com/adah1972/libunibreak/"
description="Implementation of line-breaking algorithm."
version=$(gh_ver $repo)
filename="$name-${name}_${version//./_}.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "${name}_${version//./_}" "$filename"
unpk_enter "$filename" "$direname"
sudo ./bootstrap
sudo chown $USER -R .
cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
