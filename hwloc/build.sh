#!/bin/bash
set -e
depends=(libpciaccess)
NAME=hwloc
VERSION=$(wget -cqO- https://www.open-mpi.org/projects/hwloc/ | grep -i download | grep -v '>Download<' | cut -d '"' -f 2 | cut -d '/' -f 5 | sed 's/^v//g' | head -n 1)
filename="$NAME-$VERSION.tar.bz2"
if ! [[ -f $filename ]]; then
	wget -c https://www.open-mpi.org/software/hwloc/v${VERSION%.*}/downloads/$filename
fi
direname=${filename/.tar.bz2/}
rm -rf $direname
tar xf $filename
cd $direname
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./configure \
    --prefix=/usr \
    --sbindir=/usr/bin \
    --enable-plugins \
    --sysconfdir=/etc
make -j$(nproc)
sudo make install
cd ..
rm -rf $filename $direname
