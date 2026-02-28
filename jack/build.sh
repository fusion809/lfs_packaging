#!/bin/bash
# Latest tagged version won't build
set -e
depends=()
NAME=jack2
if ! [[ -d jack2 ]]; then
	git clone https://github.com/jackaudio/jack2
fi

cd $NAME
VERSION=$(git log | head -n 1 | cut -d ' ' -f 2)
git pull origin master
sed -i -e "s|python|python3|g" waf
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./waf configure \
  --prefix=/usr \
  --libdir=/usr/lib \
  --mandir=/usr/man/man1 \
  --htmldir=/usr/doc/$PRGNAM-$VERSION/html \
  --classic \
  --dbus \
  --alsa
./waf build
sudo ./waf install
cd ..
echo $VERSION > /var/lib/lfs-custom-packages/$NAME