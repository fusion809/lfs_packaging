#!/bin/bash
set -e
name=protobuf-c
repo=$name/$name
version=$(gh_ver $repo)
depends=(gcc glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
gap_patches $name
CXXFLAGS="${CXXFLAGS:--O2 -g} -std=c++20" \
cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
