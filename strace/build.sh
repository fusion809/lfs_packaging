#!/bin/bash
set -e
name=strace
homepage="https://strace.io/"
description="A diagnostic, debugging and instructional userspace tracer"
repo="$name/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="$name-$version"
depends=(bash bzip2 coreutils elfutils glibc libelf ncurses python tar wget xz zip zlib zstd)
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --enable-mpers=no
cd ..
sudo rm -rf "$direname" "$filename" "UCD.zip"
echo "$version" | sudo tee /var/lib/custom-packages/$name
