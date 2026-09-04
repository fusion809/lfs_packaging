#!/bin/bash
set -e
name=libunistring
version=$(gnu_ver libunistring)
depends=(glibc)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://ftpmirror.gnu.org/libunistring/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --disable-static --docdir=/usr/share/doc/$direname
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
