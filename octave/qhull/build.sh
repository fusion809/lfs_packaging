#!/bin/bash
pkgname=qhull
pkgver=2020.2
_pkgver=8.0.2
wget -c http://www.qhull.org/download/qhull-${pkgver%.*}-src-$_pkgver.tgz
tar xf qhull-${pkgver%.*}-src-$_pkgver.tgz
cd $pkgname-$pkgver
cmake -B build -S . \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_C_FLAGS="$CFLAGS -ffat-lto-objects" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS -ffat-lto-objects" \
    -DCMAKE_SKIP_RPATH=ON \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
  cmake --build build
  cmake --build build --target libqhull
sudo cmake --install build
