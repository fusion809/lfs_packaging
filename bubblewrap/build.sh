#!/bin/bash
set -e
name=bubblewrap
repo="containers/$name"
version=$(gh_ver $repo)
depends=(glibc libcap)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
# User namespace support is required in the kernel
if ! [[ -f $filename ]]; then
	wget -c https://github.com/containers/bubblewrap/releases/download/v$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
