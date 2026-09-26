#!/bin/bash
set -e
name=libidn2
homepage="https://www.gnu.org/software/libidn/#libidn2"
description="Free software implementation of IDNA2008, Punycode and TR46"
version=$(gl_ver libidn/libidn2)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(libunistring)
gnu_download libidn $filename
unpk_enter "$filename" "$direname"
sudo chown $USER -R .
make distclean 2>/dev/null || true
cmi --prefix=/usr --disable-static
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
