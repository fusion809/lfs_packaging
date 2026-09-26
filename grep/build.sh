#!/bin/bash
set -e
name=grep
description="A string search utility"
homepage="http://www.gnu.org/software/grep/"
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gcc glibc make pcre2 tar wget xz)
gnu_download $name $filename
unpk_enter "$filename" "$direname"
sed -i "s/echo/#echo/" src/egrep.sh
cmi --prefix=/usr
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
