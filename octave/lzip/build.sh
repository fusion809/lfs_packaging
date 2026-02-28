#!/bin/bash
set -e
NAME=lzip
VERSION=$(wget -cqO- https://download.savannah.gnu.org/releases/lzip/ | grep "lzip-[0-9.]*.tar.gz\"" | tail -n 1 | cut -d '"' -f 4 | sed 's/lzip-//g' | sed 's/.tar.gz//g')
filename="$NAME-$VERSION.tar.gz"
SRC="https://download.savannah.gnu.org/releases/$NAME/$filename"
if ! [[ -f "$NAME-$VERSION.tar.gz" ]]; then
	wget -c $SRC
fi

tar xf $filename
cd ${filename/.tar.gz/}
./configure --prefix=/usr
make -j$(nproc)
sudo make install
cd ..
rm -rf $filename ${filename/.tar.gz/}
