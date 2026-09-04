#!/bin/bash
set -e
name=libvpx
repo="webmproject/$name"
version=$(gh_ver $repo)
blfs_depends=(yasm nasm which)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/archive/v$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
find -type f | xargs touch
sed -i 's/cp -p/cp/' build/make/Makefile &&
cmi --prefix=/usr --enable-shared --disable-static
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
