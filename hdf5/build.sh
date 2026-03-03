#!/bin/bash
set -e
depends=(libaec
openmpi)
lfs_depends=(bash coreutils glib gzip make sed tar zlib)
blfs_depends=(cmake 
gcc # Fortran support is needed
java
wget)
NAME=hdf5
VERSION=$(wget -cqO- https://github.com/HDFGroup/hdf5/releases | grep "tag/[0-9]" | grep -v "alpha\|beta\|rc" | cut -d '"' -f 6 | cut -d '/' -f 6)
filename="$NAME-$VERSION.tar.gz"
direname="$NAME-${NAME}_${VERSION/_/-}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/HDFGroup/hdf5/archive/hdf5_$VERSION/$filename
fi
rm -rf $direname
tar xf $filename
export PATH=$PATH:/opt/jdk/bin/
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
cd $direname
common_cmake_args=(
  -DCMAKE_BUILD_TYPE=None
  -DCMAKE_INSTALL_PREFIX=/usr
  -Wno-dev
  -DHDF5_USE_GNU_DIRS=ON
  -DBUILD_STATIC_LIBS=OFF
  -DHDF5_BUILD_CPP_LIB=ON
  -DHDF5_BUILD_HL_LIB=ON
  -DHDF5_BUILD_FORTRAN=ON
  -DHDF5_BUILD_JAVA=ON
  -DHDF5_ENABLE_ZLIB_SUPPORT=ON
  -DHDF5_ENABLE_SZIP_SUPPORT=ON
  -DHDF5_ENABLE_SZIP_ENCODING=ON
  -DHDF5_INSTALL_CMAKE_DIR=lib/cmake/hdf5
)
cmake -S . -B build "${common_cmake_args[@]}"
make -j$(nproc)
sudo make install
cd ..
sudo rm -rf $direname $filename
echo $VERSION > /var/lib/lfs-custom-packages/$NAME
