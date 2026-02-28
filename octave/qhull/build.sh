#!/bin/bash
set -e
NAME=qhull
VERSION=$(wget -cqO- http://www.qhull.org/download/ | grep ".tgz\"" | sed 's/.*Download: Qhull //g' | sed 's/ for Unix.*//g')
_VERSION=$(wget -cqO- http://www.qhull.org/download/ | grep ".tgz\"" | cut -d '"' -f 2 | cut -d '/' -f 5 | cut -d '-' -f 4 | sed 's/.tgz//')
filename=$NAME-${VERSION%.*}-src-$_VERSION.tgz
if ! [[ -f $filename ]]; then
	wget -c http://www.qhull.org/download/$filename
fi
tar xf $filename
cd $NAME-$VERSION
cmake -B build -S . \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_C_FLAGS="$CFLAGS -ffat-lto-objects" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS -ffat-lto-objects" \
    -DCMAKE_SKIP_RPATH=ON \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build build
cmake --build build --target libqhull
sudo cmake --install build
cd ..
rm -rf $filename $NAME-$VERSION
