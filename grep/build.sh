#!/bin/bash
set -e
name=grep
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gcc glibc make tar wget xz pcre2)
gnu_download $name $filename
rm -rf $direname
tar xf $filename
cd $direname
sed -i "s/echo/#echo/" src/egrep.sh
cmi --prefix=/usr
cd ..
rm -rf $filename $direname
echo "$version" sudo tee /var/lib/custom-packages/$name
