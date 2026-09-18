#!/bin/bash
set -e
name=gdbm
version=$(gnu_ver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(gcc glibc gzip make ncurses readline tar wget)
gnu_download $name $filename
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static --enable-libgdbm-compat
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
