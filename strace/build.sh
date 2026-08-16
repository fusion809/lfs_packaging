#!/bin/bash
set -e
name=strace
repo="$name/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="$name-$version"
lfs_depends=(wget python zip coreutils bash tar xz)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/archive/v$version/$filename
fi
tar xf "$filename"
cd "$direname"
./configure --prefix=/usr --enable-mpers=no
make -j$(nproc)
sudo make install
cd ..
sudo rm -rf "$direname" "$filename" "UCD.zip"
echo "$version" > /var/lib/custom-packages/$name
