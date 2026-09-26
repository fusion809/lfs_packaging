#!/bin/bash
set -e
name=hwdata
homepage="https://github.com/vcrhonek/hwdata"
description="hardware identification databases"
repo=vcrhonek/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-blacklist
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
