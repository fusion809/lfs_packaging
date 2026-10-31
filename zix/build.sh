#!/bin/bash
set -e
name=zix
repo=drobilla/$name
homepage="https://gitlab.com/drobilla/zix"
description="Lightweight C99 portability/data structure library."
version=$(gl_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://download.drobilla.net/$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
