#!/bin/bash
pkgname=numactl
pkgver=2.0.19
wget -c https://github.com/numactl/numactl/archive/v$pkgver.tar.gz -O $pkgname-$pkgver.tar.gz
rm -rf $pkgname-$pkgver
tar xf $pkgname-$pkgver.tar.gz
cd $pkgname-$pkgver
autoreconf -fiv
./configure --prefix=/usr
# prevent excessive overlinking due to libtool
  sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
  make -j$(nproc)
  sudo make install
sudo install -vDm 644 README.md -t "/usr/share/doc/$pkgname-$pkgver/"
