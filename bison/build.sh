#!/bin/bash
set -e
name=bison
description="The GNU general-purpose parser generator"
homepage="http://www.gnu.org/software/bison/"
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gcc gettext glibc make ncurses tar wget xz)
gnu_download $name $filename
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --docdir=/usr/share/doc/"$direname"
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
