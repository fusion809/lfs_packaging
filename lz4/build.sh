#!/bin/bash
set -e
name=lz4
homepage="https://lz4.github.io/lz4/"
description="Extremely fast compression algorithm."
repo=$name/$name
version=$(gh_ver $repo)
depends=(coreutils gcc glibc gzip make tar)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
make BUILD_STATIC=yes PREFIX=/usr -j$(nproc)
sudo make BUILD_STATIC=yes PREFIX=/usr install
cd ..
sudo rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
