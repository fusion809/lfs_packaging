#!/bin/bash
set -e
name=automake
homepage="https://www.gnu.org/software/automake"
description="A GNU tool for automatically creating Makefiles"
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gcc glibc make tar wget xz)
gnu_download $name $filename
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --docdir=/usr/share/doc/"$direname"
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
