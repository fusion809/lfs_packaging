#!/bin/bash
set -e
name=libidn2
version=$(gl_ver libidn/libidn2)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
blfs_depends=(libunistring)
if ! [[ -f $filename ]]; then
	wget -c https://ftpmirror.gnu.org/libidn/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --disable-static
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
