#!/bin/bash
set -e
name=itstool
repo=$name/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
gap_patches "$name" || echo "Patching failed"
PYTHON=/usr/bin/python3 ./autogen.sh --prefix=/usr
maki
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
