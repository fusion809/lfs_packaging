#!/bin/bash
pkgname=SuiteSparse
pkgver=7.12.2
wget -c https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/v$pkgver.tar.gz -O $pkgname-$pkgver.tar.gz
rm -rf $pkgname-$pkgver
tar xf $pkgname-$pkgver.tar.gz
cd $pkgname-$pkgver
CMAKE_OPTIONS="-DBLA_VENDOR=Generic \
                 -DCMAKE_INSTALL_PREFIX=/usr \
                 -DCMAKE_BUILD_TYPE=None \
                 -DNSTATIC=ON" \
  make -j$(nproc)
sudo make install
