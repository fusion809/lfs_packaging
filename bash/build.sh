#!/bin/bash
set -e
name=bash
version=$(gnu_ver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
lfs_depends=(gcc glibc gzip make ncurses readline tar wget)
gnu_download $name $filename
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --without-bash-malloc --with-installed-readline --docdir=/usr/share/doc/"$direname"
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
