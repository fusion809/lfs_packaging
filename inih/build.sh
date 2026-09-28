#!/bin/bash
set -e
name=inih
repo=benhoyt/$name
homepage="https://github.com/$repo"
description="Simple .INI file parser in C, good for embedded systems."
version=$(gh_ver $repo | sed 's/^r//g')
filename="$name-r$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "r$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
