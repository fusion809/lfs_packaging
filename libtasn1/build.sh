#!/bin/bash
set -e
name=libtasn1
version=$(gnu_ver libtasn1)
filename="$name-v${version}.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.com/gnutls/libtasn1/-/archive/v${version}/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
if [[ -f /var/lib/custom-packages/help2man ]]; then
	cmi --prefix=/usr --disable-static
else
	cmi --prefix=/usr --disable-static --enable-doc=no
fi
sudo make -C doc/reference install-data-local
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
