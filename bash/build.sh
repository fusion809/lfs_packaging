#!/bin/bash
set -e
name=bash
homepage="https://www.gnu.org/software/bash/bash.html"
description="The GNU Bourne Again shell"
version=$(gnu_ver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(gcc glibc gzip make ncurses readline tar wget)
gnu_download $name $filename
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --without-bash-malloc --with-installed-readline --docdir=/usr/share/doc/"$direname"
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
