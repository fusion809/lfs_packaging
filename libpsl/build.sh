#!/bin/bash
set -e
name=libpsl
repo="rockdaboot/libpsl"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
blfs_depends=(libidn2 libunistring)
depends=(glibc libidn2 libunistring)
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
