#!/bin/bash
set -e
name=gdbm
version=$(gnu_ver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(gcc glibc make ncurses readline tar wget gzip)
gnu_download $name $filename
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --disable-static --enable-libgdbm-compat
cd ..
rm -rf $filename $direname
echo "$version" sudo tee /var/lib/custom-packages/$name
