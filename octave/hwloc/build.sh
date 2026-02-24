#!/bin/bash
NAME=hwloc
VERSION=$(wget -cqO- https://www.open-mpi.org/projects/hwloc/ | grep -i download | grep -v '>Download<' | cut -d '"' -f 2 | cut -d '/' -f 5 | sed 's/^v//g' | head -n 1)
if ! [[ -f ${NAME}-${VERSION}.tar.bz2 ]]; then
	wget -c https://www.open-mpi.org/software/hwloc/v${VERSION%.*}/downloads/${NAME}-${VERSION}.tar.bz2
fi
rm -rf $NAME-$VERSION
tar xf $NAME-$VERSION.tar.bz2
cd $NAME-$VERSION
./configure \
    --prefix=/usr \
    --sbindir=/usr/bin \
    --enable-plugins \
    --sysconfdir=/etc
make -j$(nproc)
sudo make install
