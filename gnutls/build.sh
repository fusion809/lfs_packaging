#!/bin/bash
set -e
name=gnutls
repo="$name/$name"
version=$(gh_ver $repo)
majMinVer=$(echo $version | cut -d '.' -f1-2)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(libtasn1 libunistring make-ca nettle p11-kit)
download_src "https://www.gnupg.org/ftp/gcrypt/$name/v$majMinVer/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --docdir=/usr/share/doc/$direname --with-default-trust-store-pkcs11="pkcs11:"
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
