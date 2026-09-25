#!/bin/bash
set -e
name=mpc
homepage="https://www.multiprecision.org"
version=$(gnu_ver $name)
depends=(glibc gmp mpfr)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gnu_download $name $filename
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static --docdir=/usr/share/doc/$direname
make html
sudo make install-html
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
