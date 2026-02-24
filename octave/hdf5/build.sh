#!/bin/bash
set -e
NAME=hdf5
pkgbase=$NAME
VERSION=$(wget -cqO- https://github.com/HDFGroup/hdf5/releases | grep "tag/[0-9]" | cut -d '"' -f 6 | cut -d '/' -f 6)
if ! [[ -f $NAME-$VERSION.tar.gz ]]; then
	wget -c https://github.com/HDFGroup/hdf5/archive/hdf5_$VERSION/$NAME-$VERSION.tar.gz
fi
rm -rf ${pkgbase}-${pkgbase}-${VERSION/_/-}
tar xf $NAME-$VERSION.tar.gz
export PATH=$PATH:/opt/OpenJDK-21.0.9-bin/bin/
cd ${pkgbase}-${pkgbase}_${VERSION/_/-}
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
