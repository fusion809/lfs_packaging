#!/bin/bash
set -e
name=texinfo
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gcc glibc make tar wget xz)
gnu_download $name $filename
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr
cd ..
rm -rf $filename $direname
echo "$version" sudo tee /var/lib/custom-packages/$name
