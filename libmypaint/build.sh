#!/bin/bash
set -e
name=libmypaint
repo=mypaint/$name
homepage="https://github.com/mypaint/libmypaint"
description="Library for making brushstrokes which is used by MyPaint and other projects."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
