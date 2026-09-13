#!/bin/bash
set -e
name=xz
repo=tukaani-project/$name
version=$(gh_ver $repo)
lfs_depends=(glibc gcc make xz gzip tar coreutils)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
    wget -c --progress=bar:force https://github.com/$repo/releases/download/v$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --disable-static --docdir=/usr/share/doc/$direname
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
