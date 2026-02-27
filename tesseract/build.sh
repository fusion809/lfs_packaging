#!/bin/bash
NAME=tesseract
VERSION=$(wget -cqO- https://github.com/tesseract-ocr/tesseract/releases | grep "/tag/" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6)
filename="$NAME-$VERSION.tar.gz"

if ! [[ -f $filename ]]; then
	wget -c https://github.com/tesseract-ocr/tesseract/archive/$VERSION.tar.gz -O $filename
fi

rm -rf ${filename/.tar.gz/}
tar xf $filename
cd ${filename/.tar.gz/}
./autogen.sh
./configure --prefix=/usr
make -j$(nproc)
sudo make install
