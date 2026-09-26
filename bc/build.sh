#!/bin/bash
set -e
name=bc
homepage="https://www.gnu.org/software/bc/"
description="An arbitrary precision calculator language"
repo="gavinhoward/bc"
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
depends=(coreutils gcc glibc make ncurses readline tar xz)
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
CC='gcc -std=c99' cmi --prefix=/usr -G -O3 -r
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
