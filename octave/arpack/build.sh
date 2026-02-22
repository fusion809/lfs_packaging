#!/bin/bash
NAME="arpack"
PRGNAM="arpack-ng"
VERSION=3.9.1
wget -c https://github.com/opencollab/arpack-ng/archive/$VERSION.tar.gz -O $NAME-$VERSION.tar.gz
rm -rf $PRGNAM-$VERSION
tar xf $NAME-$VERSION.tar.gz
cd $PRGNAM-$VERSION
./bootstrap
./configure --enable-icb --enable-mpi --prefix=/usr
  make F77=mpif77 \
    CFLAGS+=" $(pkg-config --cflags ompi-f77) " \
    LIBS+=" $(pkg-config --libs ompi-f77) " -j$(nproc)
sudo make install

