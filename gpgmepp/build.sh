#!/bin/bash
set -e
name=gpgmepp
homepage="https://git.gnupg.org/cgi-bin/gitweb.cgi?p=gpgmepp.git;a=summary"
repo="gpg/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
depends=(gcc glibc gnupg gpgme libassuan libgpg-error)
download_src "https://www.gnupg.org/ftp/gcrypt/$name/$filename"
unpk_enter "$filename" "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
