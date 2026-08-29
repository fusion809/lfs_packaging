#!/bin/bash
set -e
name=gawk
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
lfs_depends=(gcc glibc gmp make mpfr ncurses readline tar wget xz)
if ! [[ -f $filename ]]; then
    wget -c https://ftpmirror.gnu.org/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
sed -i 's/extras//' Makefile.in
cmi --prefix=/usr
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name