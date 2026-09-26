#!/bin/bash
set -e
name=libraw
homepage="https://www.libraw.org/"
description="A library for reading RAW files obtained from digital photo cameras (CRW/CR2, NEF, RAF, DNG, and others)"
repo=$name/$name
version=$(gh_ver $repo)
depends=(gcc glibc lcms2 libjpeg-turbo zlib)
filename="LibRaw-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://www.libraw.org/data/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --enable-jpeg --enable-jasper --enable-lcms --disable-static --docdir=/usr/share/doc/libraw-$version
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
