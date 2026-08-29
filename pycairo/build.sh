#!/bin/bash
set -e
name=pycairo
repo="pygobject/$name"
version=$(gh_ver $repo)
majVer=$(echo $version | sed 's/.[0-9]$//g')
blfs_depends=(cairo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/pygobject/pycairo/releases/download/v$version/$filename
fi

rm -rf $direname
tar xf $filename
cd $direname
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf $direname $filename
echo "$version" > /var/lib/custom-packages/$name
