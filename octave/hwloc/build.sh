#!/bin/bash
pkgname=hwloc
pkgver=2.13.0
wget -c https://www.open-mpi.org/software/hwloc/v${pkgver%.*}/downloads/${pkgname}-${pkgver}.tar.bz2
rm -rf $pkgname-$pkgver
tar xf $pkgname-$pkgver.tar.bz2
cd $pkgname-$pkgver
./configure \
    --prefix=/usr \
    --sbindir=/usr/bin \
    --enable-plugins \
    --sysconfdir=/etc
make -j$(nproc)
sudo make install
