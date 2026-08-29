#!/bin/bash
set -e
name=dejagnu
version=$(gnu_ver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
lfs_depends=(glibc gcc make tar wget gzip)
if ! [[ -f $filename ]]; then
    wget -c https://ftpmirror.gnu.org/$name/$filename
fi
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
echo "$version" > /var/lib/custom-packages/$name