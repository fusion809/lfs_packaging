#!/bin/bash
set -e
name=sord
repo=drobilla/$name
homepage="https://drobilla.net/software/sord.html"
description="Lightweight C library for storing RDF data in memory."
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(glibc meson pcre2 serd zix)
download_src "https://download.drobilla.net/$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
