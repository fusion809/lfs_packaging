#!/bin/bash
pkgname=sundials
pkgver=7.6.0
wget -c https://github.com/llnl/sundials/archive/refs/tags/v$pkgver.tar.gz -O $pkgname-$pkgver.tar.gz
tar xf $pkgname-$pkgver.tar.gz
cd $pkgname-$pkgver
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
    -DEXAMPLES_INSTALL_PATH=/usr/share/sundials/examples
  cmake --build build
  sudo cmake --install build

