#!/bin/bash
set -e
name=chrpath
repo=pere/$name
homepage="https://codeberg.org/pere/chrpath"
description="Change/delete the rpath or runpath in ELF files."
version=$(cb_ver $repo)
depends=(ssw)
filename="release-$version.tar.gz"
direname="$name"
download_src "https://codeberg.org/pere/chrpath/archive/$filename"
unpk_enter "$filename" "$direname"
sh bootstrap
./configure --prefix=/usr --mandir=/usr/share/man
make -j$(nproc)
sudo make docdir=/usr/share/man/doc/chrpath install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
