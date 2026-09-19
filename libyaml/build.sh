#!/bin/bash
set -e
name=libyaml
repo="yaml/$name"
version=$(gh_ver $repo)
depends=(glibc)
filename="yaml-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
