#!/bin/bash
set -e
name=strace
repo="$name/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="$name-$version"
depends=(bash bzip2 coreutils elfutils glibc libelf ncurses python tar wget xz zip zlib zstd)
ghr_download "$repo" "v$version" "$filename"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr --enable-mpers=no
cd ..
sudo rm -rf "$direname" "$filename" "UCD.zip"
echo "$version" | sudo tee /var/lib/custom-packages/$name
