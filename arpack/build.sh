#!/bin/bash
set -e
# Variable declarations
name="arpack"
_name="arpack-ng"
version=$(wget -cqO- https://github.com/opencollab/arpack-ng/tags | grep ".tar.gz" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 4 | cut -d '/' -f 7 | sed 's/.tar.gz//g')
depends=(lapack openmpi)
lfs_depends=(bash coreutils gzip make sed tar)
blfs_depends=(gcc # Fortran support needed
wget)
filename="$_name-$version.tar.gz"
direname=${filename/.tar.gz/}
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/opencollab/arpack-ng/archive/$version.tar.gz -O $filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./bootstrap
./configure --enable-icb --enable-mpi --prefix=/usr
  make F77=mpif77 \
    CFLAGS+="-O2 -fPIC $(pkg-config --cflags ompi-f77) " \
    LIBS+=" $(pkg-config --libs ompi-f77) " -j$(nproc)
sudo make install
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/lfs-custom-packages/$name