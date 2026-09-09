#!/bin/bash
set -e
name=zip
version=$(aver $name)
depends=(bzip2 glibc)
filename="${name}${version/./}.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://downloads.sourceforge.net/infozip/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
make -f unix/Makefile generic CC="gcc -std=gnu89"
sudo make prefix=/usr MANDIR=/usr/share/man/man1 -f unix/Makefile install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
