#!/bin/bash
set -e
name=gpgmepp
repo="gpg/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
depends=(gcc glibc gnupg gpgme libassuan libgpg-error)
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://www.gnupg.org/ftp/gcrypt/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmaki -D CMAKE_INSTALL_PREFIX=/usr
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
