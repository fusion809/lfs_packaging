#!/bin/bash
pkgname=portaudio
pkgver=19.7.0
wget -c https://github.com/portaudio/portaudio/archive/v$pkgver/$pkgname-v$pkgver.tar.gz
tar xf $pkgname-v$pkgver.tar.gz
cd $pkgname-$pkgver
cd bindings/cpp
autoreconf -fiv
cd ../..
autoreconf -fiv
configure_options=(
    --prefix=/usr
    --enable-cxx
  )
./configure "${configure_options[@]}"
make -j1
sudo make install
sudo install -Dmv644 README.* /usr/share/doc/$pkgname-$pkgver/
