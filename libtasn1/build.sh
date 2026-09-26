#!/bin/bash
set -e
name=libtasn1
homepage="https://www.gnu.org/software/libtasn1/"
description="The ASN.1 library used in GNUTLS"
version=$(gnu_ver libtasn1)
depends=(coreutils gcc glibc gzip make tar wget)
filename="$name-v${version}.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://gitlab.com/gnutls/libtasn1/-/archive/v${version}/$filename"
unpk_enter "$filename" "$direname"
if [[ -f /var/lib/custom-packages/help2man ]]; then
	cmi --prefix=/usr --disable-static
else
	cmi --prefix=/usr --disable-static --enable-doc=no
fi
sudo make -C doc/reference install-data-local
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
