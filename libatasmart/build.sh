#!/bin/bash
set -e
name=libatasmart
repo=$name/$name
version=$(gh_ver $repo)
depends=(glibc systemd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://0pointer.de/public/$filename"
unpk_enter "$filename" "$direname"
./configure --prefix=/usr --disable-static
make -j$(nproc)
sudo make docdir=/usr/share/doc/$direname install
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
