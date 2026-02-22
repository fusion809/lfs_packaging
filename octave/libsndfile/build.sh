#!/bin/bash
pkgname=libsndfile
pkgver=1.2.2
rm -rf $pkgname-$pkgver
wget -c https://github.com/$pkgname/$pkgname/releases/download/$pkgver/$pkgname-$pkgver.tar.xz
wget -c https://github.com/libsndfile/libsndfile/commit/0754562e13d2e63a248a1c82f90b30bc0ffe307c.patch -O $pkgname-$pkgver-CVE-2022-33065.patch
tar xf $pkgname-$pkgver.tar.xz
cd $pkgname-$pkgver
patch -Np1 -i ../$pkgname-1.2.2-CVE-2022-33065.patch
 cmake_options=(
    -B build
    -D BUILD_SHARED_LIBS=ON
    -D CMAKE_INSTALL_PREFIX=/usr
    -D CMAKE_BUILD_TYPE=None
    -D CMAKE_POLICY_VERSION_MINIMUM=3.5
    -D ENABLE_EXTERNAL_LIBS=ON
    -D ENABLE_MPEG=ON
    -S .
    -W no-dev
  )

  cmake "${cmake_options[@]}"
  cmake --build build --verbose
 sudo cmake --install build
  sudo install -vDm 644 {AUTHORS,ChangeLog,README} -t "/usr/share/doc/$pkgname-$pkgver"

