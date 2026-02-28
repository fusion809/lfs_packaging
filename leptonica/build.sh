#!/bin/bash
set -e
NAME="leptonica"
VERSION=$(wget -cqO- https://github.com/DanBloomberg/leptonica/releases | grep "/tag/" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6)
filename="$NAME-$VERSION.tar.gz"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/DanBloomberg/leptonica/archive/ref/tags/${VERSION}.tar.gz -O $filename
fi
rm -rf ${filename/.tar.gz/}
tar xf $filename
cd ${filename/.tar.gz/}
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./autogen.sh --prefix=/usr
./configure --prefix=/usr
make -j$(nproc)
sudo make install
cd ..
rm -rf ${filename/.tar.gz/} $filename
