#!/bin/bash
set -e
name=help2man
version=$(gnu_ver help2man)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(wget tar xz make gcc coreutils)
if ! [[ -f $filename ]]; then
	wget -c https://ftp.gnu.org/gnu/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --mandir=/usr/share/man --infodir=/usr/share/info --libdir=/usr/lib
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
