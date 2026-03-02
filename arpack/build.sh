#!/bin/bash
set -e
depends=(openmpi)
NAME="arpack"
PRGNAME="arpack-ng"
VERSION=$(wget -cqO- https://github.com/opencollab/arpack-ng/tags | grep ".tar.gz" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 4 | cut -d '/' -f 7 | sed 's/.tar.gz//g')
filename="$PRGNAME-$VERSION.tar.gz"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/opencollab/arpack-ng/archive/$VERSION.tar.gz -O $filename
fi
direname=${filename/.tar.gz/}
rm -rf $direname
tar xf $filename
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./bootstrap
./configure --enable-icb --enable-mpi --prefix=/usr
  make F77=mpif77 \
    CFLAGS+="-O2 -fPIC $(pkg-config --cflags ompi-f77) " \
    LIBS+=" $(pkg-config --libs ompi-f77) " -j$(nproc)
sudo make install
cd ..
sudo rm -rf $filename $direname
echo $VERSION > /var/lib/lfs-custom-packages/$NAME