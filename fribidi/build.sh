#!/bin/bash
set -e
name=fribidi
homepage="https://github.com/fribidi/fribidi"
description="A Free Implementation of the Unicode Bidirectional Algorithm"
repo=$name/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
