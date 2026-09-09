#!/bin/bash
set -e
name=libraw
repo=$name/$name
version=$(gh_ver $repo)
depends=(gcc glibc lcms2 libjpeg-turbo zlib)
filename="LibRaw-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.libraw.org/data/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr --enable-jpeg --enable-jasper --enable-lcms --disable-static --docdir=/usr/share/doc/libraw-$version
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
