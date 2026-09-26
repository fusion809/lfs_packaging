#!/bin/bash
set -e
name=jpegoptim
homepage="https://github.com/tjko/jpegoptim"
description="Jpeg optimisation utility"
repo="tjko/jpegoptim"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="$name-$version"
depends=(glibc libjpeg libjpeg-turbo)
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
./configure --prefix=/usr
make -j$(nproc)
make strip -j$(nproc)
sudo make install
cd ..
rm -rf $direname $filename
echo "$version" | sudo tee /var/lib/custom-packages/$name
