#!/bin/bash
set -e
depends=(leptonica)
lfs_depends=(bash coreutils gcc glibc gzip make tar)
blfs_depends=(icu libarchive pango wget)
name=tesseract
version=$(wget -cqO- https://github.com/tesseract-ocr/tesseract/releases | grep "/tag/" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6)
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/tesseract-ocr/tesseract/archive/$version.tar.gz -O $filename
fi

rm -rf $direname
tar xf $filename
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./autogen.sh
./configure --prefix=/usr
make -j$(nproc)
sudo make install
cd ..
rm -rf $filename $direname
echo $version > /var/lib/lfs-custom-packages/$name