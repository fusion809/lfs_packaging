#!/bin/bash
set -e
NAME="arpack"
NAME="arpack-ng"
VERSION=$(wget -cqO- https://github.com/opencollab/arpack-ng/tags | grep ".tar.gz" | head -n 1 | cut -d '"' -f 4 | cut -d '/' -f 7 | sed 's/.tar.gz//g')
filename="$NAME-$VERSION.tar.gz"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/opencollab/arpack-ng/archive/$VERSION.tar.gz -O $filename
fi
rm -rf ${filename/.tar.gz/}
tar xf $filename
cd ${filename/.tar.gz/}
./bootstrap
./configure --enable-icb --enable-mpi --prefix=/usr
  make F77=mpif77 \
    CFLAGS+=" $(pkg-config --cflags ompi-f77) " \
    LIBS+=" $(pkg-config --libs ompi-f77) " -j$(nproc)
sudo make install
cd ..
rm -rf $filename ${filename/.tar.gz/}
