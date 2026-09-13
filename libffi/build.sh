#!/bin/bash
set -e
name=libffi
repo=libffi/libffi
version=$(gh_ver $repo)
lfs_depends=(glibc gcc make gzip tar coreutils)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
    wget -c --progress=bar:force https://github.com/$repo/releases/download/v$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --disable-static --with-gcc-arch=native
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
