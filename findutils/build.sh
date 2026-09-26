#!/bin/bash
set -e
name=findutils
homepage="https://www.gnu.org/software/findutils/"
description="GNU utilities to locate files"
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gcc glibc make tar wget xz)
gnu_download $name $filename
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --localstatedir=/var/lib/locate
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
