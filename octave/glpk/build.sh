#!/bin/bash
pkgname=glpk
pkgver=5.0
wget -c https://ftp.gnu.org/gnu/glpk/$pkgname-$pkgver.tar.gz
wget -c "https://gitlab.archlinux.org/archlinux/packaging/packages/glpk/-/raw/main/gcc-15.patch?ref_type=heads&inline=false" -O gcc-15.patch
tar xf $pkgname-$pkgver.tar.gz
cd $pkgname-$pkgver
patch -Np1 -i ../gcc-15.patch
autoreconf -fiv
./configure --prefix=/usr --with-gmp
make -j$(nproc)
sudo make install
