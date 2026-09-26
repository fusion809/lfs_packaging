#!/bin/bash
set -e
name=cdparanoia
homepage="https://www.xiph.org/paranoia/"
description="Compact Disc Digital Audio extraction tool"
repo=jwilk-mirrors/$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-III-$version.src.tgz"
direname="${filename/.src.tgz/}"
download_src "https://downloads.xiph.org/releases/cdparanoia/$filename"
unpk_enter "$filename" "$direname"
gap_patches "$name" || echo "Apply patches failed... Continuing"
./configure --prefix=/usr --mandir=/usr/share/man
make -j1
sudo make install
sudo su -c "chmod -v 755 /usr/lib/libcdda_*.so.0.$version &&
rm -fv /usr/lib/libcdda_*.a"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
