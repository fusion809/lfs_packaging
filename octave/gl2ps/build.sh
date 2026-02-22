#!/bin/bash
pkgname=gl2ps
pkgver=1.4.2
wget -c https://geuz.org/gl2ps/src/gl2ps-${pkgver}.tgz
tar xf $pkgname-$pkgver.tgz
cd $pkgname-$pkgver
mkdir build
cd build
export FORCE_SOURCE_DATE=1 # make pdftex adhere to SOURCE_DATE_EPOCH
  cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_EXE_LINKER_FLAGS=-lm \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
  make -j$(nproc)
  sudo make install

