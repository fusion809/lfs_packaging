#!/bin/bash
set -e
name=strace
repo="$name/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="$name-$version"
lfs_depends=(bash bzip2 coreutils glibc libelf ncurses python tar wget xz zip zlib zstd)
depends=(elfutils)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/releases/download/v$version/$filename
fi
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr --enable-mpers=no
cd ..
sudo rm -rf "$direname" "$filename" "UCD.zip"
echo "$version" > /var/lib/custom-packages/$name
