#!/bin/bash
set -e
name=ocaml
repo=$name/$name
homepage="https://ocaml.org/"
description="Functional language with OO extensions."
version=$(gh_ver $repo)
depends=(gcc gmp sagemath ssw zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
CFLAGS+=' -ffat-lto-objects'
CXXFLAGS+=' -ffat-lto-objects'
./configure --prefix /usr --disable-static --mandir /usr/share/man -enable-frame-pointers
make --debug=v world.opt
sudo make install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
