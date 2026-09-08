#!/bin/bash
set -e
name=mpc
version=$(gnu_ver $name)
depends=(glibc gmp mpfr)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://ftpmirror.gnu.org/$name/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr --disable-static --docdir=/usr/share/doc/$direname
make html
sudo make install-html
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
