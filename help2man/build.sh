#!/bin/bash
set -e
name=help2man
description="Conversion tool to create man files"
homepage="http://www.gnu.org/software/help2man/"
version=$(gnu_ver help2man)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(coreutils gcc make tar wget xz)
gnu_download "$name" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --mandir=/usr/share/man --infodir=/usr/share/info --libdir=/usr/lib
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
