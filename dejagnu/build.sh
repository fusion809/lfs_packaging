#!/bin/bash
set -e
name=dejagnu
version=$(gnu_ver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(glibc gcc make tar wget gzip)
gnu_download $name $filename
rm -rf $direname
tar xf $filename
cd $direname
mkdir -v build
cd       build
../configure --prefix=/usr
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi
sudo su -c "make install
install -v -dm755  /usr/share/doc/$direname
install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/$direname"
cd ../..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
