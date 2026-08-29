#!/bin/bash
set -e
name=bash
version=$(gnu_ver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
lfs_depends=(glibc gcc tar gzip wget make readline)
if ! [[ -f $filename ]]; then
    wget -c https://ftpmirror.gnu.org/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --without-bash-malloc --with-installed-readline --docdir=/usr/share/doc/"$direname"
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name