#!/bin/bash
set -e
name=m4
description="The GNU macro processor"
homepage="http://www.gnu.org/software/m4/"
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gcc glibc make tar wget xz)
gnu_download $name $filename
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
