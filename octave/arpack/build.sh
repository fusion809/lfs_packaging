#!/bin/bash
NAME="arpack"
PRGNAM="arpack-ng"
VERSION=$(wget -cqO- https://github.com/opencollab/arpack-ng/tags | grep ".tar.gz" | head -n 1 | cut -d '"' -f 4 | cut -d '/' -f 7 | sed 's/.tar.gz//g')
if ! [[ -f "$NAME-$VERSION.tar.xz" ]]; then
	wget -c https://github.com/opencollab/arpack-ng/archive/$VERSION.tar.gz -O $NAME-$VERSION.tar.gz
fi
rm -rf $PRGNAM-$VERSION
tar xf $NAME-$VERSION.tar.gz
cd $PRGNAM-$VERSION
./bootstrap
./configure --enable-icb --enable-mpi --prefix=/usr
  make F77=mpif77 \
    CFLAGS+=" $(pkg-config --cflags ompi-f77) " \
    LIBS+=" $(pkg-config --libs ompi-f77) " -j$(nproc)
sudo make install

