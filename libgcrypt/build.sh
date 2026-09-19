#!/bin/bash
set -e
name=libgcrypt
repo="gpg/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
depends=(glibc libgpg-error)
download_src "https://www.gnupg.org/ftp/gcrypt/$name/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
make -C doc html                                                       &&
makeinfo --html --no-split -o doc/gcrypt_nochunks.html doc/gcrypt.texi &&
makeinfo --plaintext       -o doc/gcrypt.txt           doc/gcrypt.texi
sudo su -c "install -v -dm755   /usr/share/doc/$direname &&
install -v -m644    README doc/{README.apichanges,fips*,libgcrypt*} \
                    /usr/share/doc/$direname &&

install -v -dm755   /usr/share/doc/$direname/html &&
install -v -m644 doc/gcrypt.html/* \
                    /usr/share/doc/$direname/html &&
install -v -m644 doc/gcrypt_nochunks.html \
                    /usr/share/doc/$direname      &&
install -v -m644 doc/gcrypt.{txt,texi} \
                    /usr/share/doc/$direname"
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
