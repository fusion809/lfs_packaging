#!/bin/bash
set -e
name=zstd
repo=facebook/$name
version=$(gh_ver $repo)
depends=(coreutils gcc glibc gzip make tar)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
make prefix=/usr
sudo make prefix=/usr install
sudo rm -v /usr/lib/libzstd.a
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
