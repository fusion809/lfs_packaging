#!/bin/bash
set -e
name=lz4
homepage="https://lz4.github.io/lz4/"
description="Extremely fast compression algorithm"
repo=$name/$name
version=$(gh_ver $repo)
depends=(coreutils gcc glibc gzip make tar)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
make BUILD_STATIC=no PREFIX=/usr -j$(nproc)
sudo make BUILD_STATIC=no PREFIX=/usr install
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
