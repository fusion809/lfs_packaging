#!/bin/bash
pkgname=libfabric
pkgver=2.4.0
wget -c https://github.com/ofiwg/libfabric/releases/download/v$pkgver/$pkgname-$pkgver.tar.bz2
rm -rf $pkgname-$pkgver
tar xf $pkgname-$pkgver.tar.bz2
cd $pkgname-$pkgver
autoreconf -fvi
./configure --prefix=/usr
sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
  make -j$(nproc)
  sudo make install
