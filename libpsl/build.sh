#!/bin/bash
set -e
name=libpsl
repo="rockdaboot/libpsl"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(glibc libidn2 libidn2 libunistring libunistring)
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/$version/$filename
fi
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
