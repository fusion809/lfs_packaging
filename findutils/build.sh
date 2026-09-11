#!/bin/bash
set -e
name=findutils
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(glibc gcc make tar wget xz)
gnu_download $name $filename
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --localstatedir=/var/lib/locate
cd ..
rm -rf $filename $direname
echo "$version" sudo tee /var/lib/custom-packages/$name
