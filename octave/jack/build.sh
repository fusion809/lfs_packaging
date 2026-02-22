#!/bin/bash
# Latest tagged version won't build
pkgname=jack2
if ! [[ -d jack2 ]]; then
	git clone https://github.com/jackaudio/jack2
fi

cd $pkgname
pkgver=$(git log | head -n 1 | cut -d ' ' -f 2)
git pull origin master
sed -i -e "s|python|python3|g" waf
./waf configure \
  --prefix=/usr \
  --libdir=/usr/lib${LIBDIRSUFFIX} \
  --mandir=/usr/man/man1 \
  --htmldir=/usr/doc/$PRGNAM-$VERSION/html \
  --classic \
  --dbus \
  --alsa
./waf build
sudo ./waf install
