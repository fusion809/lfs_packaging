#!/bin/bash
set -e
depends=(lapack openmpi suitesparse)
NAME=sundials
VERSION=$(wget -cqO- https://github.com/llnl/sundials/releases | grep "releases/tag/v" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6 | sed 's/^v//g')
filename=$NAME-$VERSION.tar.gz
direname="${filename/.tar.gz/}"
wget -c https://github.com/llnl/sundials/archive/refs/tags/v$VERSION.tar.gz -O $filename
tar xf $filename
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
cmake -B build -S . \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DBUILD_STATIC_LIBS=OFF \
    -DENABLE_MPI=ON \
    -DENABLE_PTHREAD=ON	\
    -DENABLE_OPENMP=ON \
    -DENABLE_KLU=ON \
    -DKLU_LIBRARY_DIR=/usr/lib \
    -DKLU_INCLUDE_DIR=/usr/include/suitesparse \
    -DENABLE_LAPACK=ON \
    -DEXAMPLES_INSTALL_PATH=/usr/share/sundials/examples \
    -DCMAKE_C_FLAGS="$CFLAGS" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
cmake --build build
sudo cmake --install build
cd ..
rm -rf $filename ${filename/.tar.gz/}
