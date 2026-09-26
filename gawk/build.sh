#!/bin/bash
set -e
name=gawk
homepage="https://www.gnu.org/software/gawk/"
description="GNU version of awk"
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gcc glibc gmp make mpfr ncurses readline tar wget xz)
gnu_download $name $filename
unpk_enter "$filename" "$direname"
sed -i 's/extras//' Makefile.in
cmi --prefix=/usr
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
