#!/bin/bash
set -e
name=lz4
repo=$name/$name
version=$(gh_ver $repo)
lfs_depends=(glibc gcc make gzip tar coreutils)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
    wget -c https://github.com/$repo/releases/download/v$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
make BUILD_STATIC=no PREFIX=/usr -j$(nproc)
sudo make BUILD_STATIC=no PREFIX=/usr install
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
