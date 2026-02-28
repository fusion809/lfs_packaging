#!/bin/bash
set -e
NAME=libfabric
VERSION=$(wget -cqO- https://github.com/ofiwg/libfabric/releases | grep "releases/tag/v[0-9].[0-9]" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6 | sed 's/v//g')
filename="$NAME-$VERSION.tar.bz2"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/ofiwg/libfabric/releases/download/v$VERSION/$filename
fi
rm -rf ${filename/.tar.bz2/}
tar xf $filename
cd ${filename/.tar.bz2/}
autoreconf -fvi
./configure --prefix=/usr
sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
make -j$(nproc)
sudo make install
cd ..
rm -rf ${filename/.tar.bz2/} $filename
