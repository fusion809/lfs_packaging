#!/bin/bash
set -e
name=icu
repo="unicode-org/$name"
version=$(gh_ver $repo)
filename="${name}4c-$version-sources.tgz"
direname="${filename/.tgz/}"
ghr_download "$repo" "release-$version" "$filename"
unpk_enter "$filename" "$name" "source"
cmi --prefix=/usr
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
