#!/bin/bash
set -e
name=libassuan
repo="gpg/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.bz2"
blfs_depends=(libgpg-error)
depends=(glibc)
if ! [[ -f $filename ]]; then
	wget -c https://www.gnupg.org/ftp/gcrypt/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr
make -C doc html
makeinfo --html --no-split -o doc/assuan_nochunks.html doc/assuan.texi &&
makeinfo --plaintext       -o doc/assuan.txt           doc/assuan.texi
sudo su -c "install -v -dm755   /usr/share/doc/$direname/html &&
install -v -m644 doc/assuan.html/* \
                    /usr/share/doc/$direname/html &&
install -v -m644 doc/assuan_nochunks.html \
                    /usr/share/doc/$direname      &&
install -v -m644 doc/assuan.{txt,texi} \
                    /usr/share/doc/$direname"
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
