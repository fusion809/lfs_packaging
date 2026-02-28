#!/bin/bash
set -e
depends=(blas lapack)
PRGNAME=SuiteSparse
NAME=suitesparse
VERSION=$(wget -cqO- https://github.com/DrTimothyAldenDavis/SuiteSparse/releases | grep "releases/tag/v" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6 | sed 's/^v//g')
filename="$PRGNAME-$VERSION.tar.gz"
direname="${filename/.tar.gz/}"
wget -c https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/v$VERSION.tar.gz -O $filename
rm -rf $direname
tar xf $filename
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
CMAKE_OPTIONS="-DBLA_VENDOR=Generic \
                 -DCMAKE_INSTALL_PREFIX=/usr \
                 -DCMAKE_BUILD_TYPE=None \
                 -DNSTATIC=ON" \
                 -DCMAKE_C_FLAGS="$CFLAGS" \
                 -DCMAKE_CXX_FLAGS="$CXXFLAGS"
make -j$(nproc)
sudo make install
cd ..
rm -rf $direname $filename
