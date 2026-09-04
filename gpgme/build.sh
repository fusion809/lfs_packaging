#!/bin/bash
set -e
name=gpgme
repo="gpg/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.bz2"
blfs_depends=(gnupg libassuan libgpg-error)
depends=(glibc)
if ! [[ -f $filename ]]; then
	wget -c https://www.gnupg.org/ftp/gcrypt/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --disable-static
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
