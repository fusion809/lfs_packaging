#!/bin/bash
pkgname=qrupdate
pkgver=1.1.5
wget -c https://github.com/mpimd-csc/qrupdate-ng/archive/v$pkgver.tar.gz -O $pkgname-$pkgver.tar.gz
rm -rf $pkgname-$pkgver
tar xf $pkgname-$pkgver.tar.gz
cd ${pkgname}-ng-$pkgver
cmake -B build -S . \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
  cmake --build build --verbose
  sudo cmake --install build
