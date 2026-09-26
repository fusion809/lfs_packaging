#!/bin/bash
set -e
name=gperf
homepage="https://www.gnu.org/software/gperf/"
description="Perfect hash function generator"
version=$(gnu_ver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(gcc glibc gzip make tar wget)
gnu_download $name $filename
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --docdir=/usr/share/doc/$direname
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
