#!/bin/bash
set -e
name=libepoxy
repo=anholt/libepoxy
version=$(gh_ver $repo)
majVer=$(echo $version | sed -E 's/.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(mesa)
gn_download "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
