#!/bin/bash
set -e
source $HOME/lfs_packaging/shared-funcs.sh
name=strace
version=$(github_ver "$name/$name" | sed 's/v//g')
filename="$name-$version.tar.xz"
direname="$name-$version"
lfs_depends=(wget python zip coreutils bash tar xz)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$name/$name/releases/download/v$version/$filename
fi
tar xf "$filename"
cd "$direname"
./configure --prefix=/usr --enable-mpers=no
make -j$(nproc)
sudo make install
cd ..
sudo rm -rf "$direname" "$filename" "UCD.zip"
echo "$version" > /var/lib/custom-packages/$name
