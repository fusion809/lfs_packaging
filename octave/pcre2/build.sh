#!/bin/bash
pkgname=pcre2
pkgver=10.47
wget -c https://github.com/PCRE2Project/pcre2/archive/$pkgname-$pkgver.tar.gz
wget -c https://github.com/zherczeg/sljit/archive/master.tar.gz -O sljit-master.tar.gz
tar xf $pkgname-$pkgver.tar.gz
cd $pkgname-$pkgname-$pkgver
rm -rf deps/sljit
tar xf ../sljit-master.tar.gz
mv sljit-master sljit 
mv sljit deps/sljit
./autogen.sh
configure_options=(
    --enable-jit
    --enable-pcre2-16
    --enable-pcre2-32
    --enable-pcre2grep-libbz2
    --enable-pcre2grep-libz
    --enable-pcre2test-libreadline
    --prefix=/usr
  )

CFLAGS+=" -ffat-lto-objects"
  CXXFLAGS+=" -ffat-lto-objects"

  ./configure "${configure_options[@]}"
  make -j$(nproc)
  sudo make install
