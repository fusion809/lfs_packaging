#!/bin/bash
set -e
name=gpgme
repo="gpg/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.bz2"
blfs_depends=(gnupg libassuan libgpg-error)
depends=(gcc glibc gpgme)
if ! [[ -f $filename ]]; then
	wget -c https://www.gnupg.org/ftp/gcrypt/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmaki -D CMAKE_INSTALL_PREFIX=/usr
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
