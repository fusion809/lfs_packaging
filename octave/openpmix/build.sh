#!/bin/bash
_name=pmix
pkgver=5.0.10
wget -c https://github.com/openpmix/openpmix/releases/download/v$pkgver/$_name-$pkgver.tar.gz
tar xf $_name-$pkgver.tar.gz
cd $_name-$pkgver
./autogen.pl
local configure_options=(
    --prefix=/usr
    --sysconfdir=/etc/$pkgname
  )

  # set environment variables for reproducible build
  # see https://docs.openpmix.org/en/latest/release-notes/general.html
  export HOSTNAME=buildhost
  export USER=builduser

  cd $_name-$pkgver
  ./configure "${configure_options[@]}"
  # prevent excessive overlinking due to libtool
  sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
  make V=1 -j$(nproc)
  sudo make install

