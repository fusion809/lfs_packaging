#!/bin/bash
pkgname=libaec
pkgver=1.1.5
wget -c https://gitlab.dkrz.de/k202009/libaec/-/archive/v$pkgver/$pkgname-v$pkgver.tar.bz2
tar xf $pkgname-v$pkgver.tar.bz2
cd $pkgname-v$pkgver
cmake -B build -S . \
    -DCMAKE_BUILD_TYPE=None \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -Wno-dev \
    -DBUILD_STATIC_LIBS=OFF
  cmake --build build
sudo cmake --install build
