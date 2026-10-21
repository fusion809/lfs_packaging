#!/bin/bash
set -e
name=ocamlbuild
repo=ocaml/$name
homepage="https://github.com/ocaml/ocamlbuild"
description="Build tools for OCaml libraries/programs."
version=$(gh_ver $repo)
depends=(ssw)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
make configure PREFIX=/usr MANDIR=/usr/share/man
make -j$(nproc)
sudo make install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
