#!/bin/bash
set -e
name=gpgme
description="C wrapper library for GnuPG"
homepage="https://gnupg.org/download/"
repo="gpg/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
depends=(glibc gnupg libassuan libgpg-error)
download_src "https://www.gnupg.org/ftp/gcrypt/$name/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
