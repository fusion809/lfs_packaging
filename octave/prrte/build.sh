#!/bin/bash
pkgname=prrte
pkgver=3.0.13
wget -c https://github.com/openpmix/prrte/releases/download/v$pkgver/$pkgname-$pkgver.tar.gz
tar xf $pkgname-$pkgver.tar.gz
cd $pkgname-$pkgver
./autogen.pl
 local configure_options=(
    --prefix=/usr
    --sysconfdir=/etc/$pkgname
  )

  # set environment variables for reproducible build
  # see https://docs.prrte.org/en/latest/release-notes.html
  export HOSTNAME=buildhost
  export USER=builduser

  cd $pkgname-$pkgver
  ./configure "${configure_options[@]}"
  # prevent excessive overlinking due to libtool
  sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
  make V=1 -j$(nproc)
  sudo make install
