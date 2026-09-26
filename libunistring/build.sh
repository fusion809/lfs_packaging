#!/bin/bash
set -e
name=libunistring
homepage="https://www.gnu.org/software/libunistring/"
description="Library for manipulating Unicode strings and C strings"
version=$(gnu_ver libunistring)
depends=(glibc)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gnu_download $name $filename
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static --docdir=/usr/share/doc/$direname
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
