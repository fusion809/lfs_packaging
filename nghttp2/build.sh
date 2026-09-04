#!/bin/bash
set -e
name=nghttp2
repo="$name/$name"
version=$(gh_ver $repo)
majVer=$(echo $version | sed 's/.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
blfs_depends=(libxml2)
depends=(gcc glibc hdf5 libaec zlib)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/releases/download/v$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --disable-static --enable-lib-only --docdir=/usr/share/doc/$direname
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
