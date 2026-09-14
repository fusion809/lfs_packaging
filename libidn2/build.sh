#!/bin/bash
set -e
name=libidn2
version=$(gl_ver libidn/libidn2)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(libunistring)
gnu_download libidn $filename
sudo rm -rf $direname
tar xf $filename
cd $direname
sudo chown $USER -R .
make distclean 2>/dev/null || true
cmi --prefix=/usr --disable-static
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
