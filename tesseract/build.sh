#!/bin/bash
set -e
# Variable declarations
name=tesseract
version=$(git ls-remote --tags https://github.com/tesseract-ocr/tesseract.git | grep -oP 'refs/tags/\K[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1)
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(leptonica)
lfs_depends=(bash coreutils gcc glibc gzip make tar)
blfs_depends=(icu libarchive pango wget)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/tesseract-ocr/tesseract/archive/$version.tar.gz -O $filename
fi
sudo rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
sudo ./autogen.sh
./configure --prefix=/usr
make -j$(nproc)
sudo make install
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
