#!/bin/bash
set -e
NAME=tesseract
VERSION=$(wget -cqO- https://github.com/tesseract-ocr/tesseract/releases | grep "/tag/" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6)
filename="$NAME-$VERSION.tar.gz"
direname="${filename/.tar.gz/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/tesseract-ocr/tesseract/archive/$VERSION.tar.gz -O $filename
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
