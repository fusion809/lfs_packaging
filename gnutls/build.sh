#!/bin/bash
set -e
name=gnutls
repo="$name/$name"
version=$(gh_ver $repo)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(nettle make-ca libunistring libtasn1 p11-kit)
if ! [[ -f $filename ]]; then
	wget -c https://www.gnupg.org/ftp/gcrypt/$name/v$majVer/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --docdir=/usr/share/doc/$direname --with-default-trust-store-pkcs11="pkcs11:"
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
