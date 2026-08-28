#!/bin/bash
name=bc
repo="gavinhoward/bc"
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
lfs_depends=(coreutils gcc glibc make ncurses readline tar xz)
if ! [[ -f $filename ]]; then
    wget -c https://github.com/$repo/releases/download/$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
CC='gcc -std=c99' cmi "--prefix=/usr -G -O3 -r"
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name