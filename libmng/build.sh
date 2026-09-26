#!/bin/bash
set -e
name=libmng
homepage="https://www.libmng.com/"
description="A collection of routines used to create and manipulate MNG format graphics files"
repo=LuaDist/$name
version=$(gh_ver $repo)
depends=(glibc lcms2 libjpeg-turbo zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://downloads.sourceforge.net/libmng/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
sudo su -c "install -v -m755 -d        /usr/share/doc/$direname &&
install -v -m644 doc/*.txt /usr/share/doc/$direname"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
