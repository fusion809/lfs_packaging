#!/bin/bash
NAME=lzip
VERSION=1.25
FILENAME="$NAME-$VERSION.tar.gz"
SRC="https://download.savannah.gnu.org/releases/$NAME/$FILENAME"
if ! [[ -f "$NAME-$VERSION.tar.gz" ]]; then
	wget -c $SRC
fi

tar xf $FILENAME
cd ${FILENAME/.tar.gz/}
./configure --prefix=/usr
make -j$(nproc)
sudo make install

