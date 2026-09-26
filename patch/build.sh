#!/bin/bash
set -e
name=patch
description="A utility to apply patch files to original sources"
homepage="https://savannah.gnu.org/projects/patch/"
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(attr gcc glibc make tar wget xz)
gnu_download $name $filename
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
