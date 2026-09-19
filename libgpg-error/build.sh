#!/bin/bash
set -e
name=libgpg-error
repo="gpg/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
depends=(glibc)
download_src "https://www.gnupg.org/ftp/gcrypt/$name/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --sysconfdir=/etc
sudo su -c "install -v -m644 -D README /usr/share/doc/$direname/README"
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
