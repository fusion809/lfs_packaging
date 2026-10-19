#!/bin/bash
set -e
name=maeparser
repo=schrodinger/$name
homepage="https://github.com/schrodinger/maeparser"
description="Maestro file parser."
version=$(gh_ver $repo)
depends=(boost bzip2 gcc glibc xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -DCMAKE_INSTALL_PREFIX=/usr
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
