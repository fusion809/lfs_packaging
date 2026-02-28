#!/bin/bash
set -e
depends=()
NAME=libaec
VERSION=$(wget -cqO- https://gitlab.dkrz.de/dkrz-sw/libaec/-/tags | grep 'tags/v' | head -n 1 | cut -d '"' -f 2 | cut -d '/' -f 6 | sed 's/v//g')
filename="$NAME-v$VERSION.tar.bz2"
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.dkrz.de/k202009/libaec/-/archive/v$VERSION/$NAME-v$VERSION.tar.bz2
fi
direname=${filename/.tar.bz2/}
rm -rf $direname
tar xf $filename
cd $direname
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
cmake -B build -S . \
    -DCMAKE_BUILD_TYPE=None \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -Wno-dev \
    -DBUILD_STATIC_LIBS=OFF
cmake --build build
sudo cmake --install build
cd ..
sudo rm -rf $filename $direname
echo $VERSION > /var/lib/lfs-custom-packages/$NAME
