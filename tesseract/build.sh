#!/bin/bash
set -e
# Variable declarations
name=tesseract
version=$(wget -cqO- https://github.com/tesseract-ocr/tesseract/releases | grep "/tag/" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6)
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(leptonica)
lfs_depends=(bash coreutils gcc glibc gzip make tar)
blfs_depends=(icu libarchive pango wget)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/tesseract-ocr/tesseract/archive/$version.tar.gz -O $filename
fi
sudo m -rf $direname
tar xf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./autogen.sh
./configure --prefix=/usr
make -j$(nproc)
sudo make install
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/lfs-custom-packages/$name