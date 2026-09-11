#!/bin/bash
set -e
name=automake
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(glibc gcc tar xz wget make)
gnu_download $name $filename
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --docdir=/usr/share/doc/"$direname"
cd ..
rm -rf $filename $direname
echo "$version" sudo tee /var/lib/custom-packages/$name
