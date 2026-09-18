#!/bin/bash
set -e
name=gperf
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
