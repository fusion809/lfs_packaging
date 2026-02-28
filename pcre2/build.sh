#!/bin/bash
set -e
depends=()
NAME=pcre2
VERSION=$(wget -cqO- https://github.com/PCRE2Project/pcre2/releases | grep "releases/tag/pcre2" | head -n 1 | cut -d '"' -f 6 | cut -d '=' -f 3 | cut -d '/' -f 6 | sed 's/pcre2-//g')
filename="$NAME-$VERSION.tar.gz"
wget -c https://github.com/PCRE2Project/pcre2/archive/$filename
wget -c https://github.com/zherczeg/sljit/archive/master.tar.gz -O sljit-master.tar.gz
tar xf $NAME-$VERSION.tar.gz
dirname="$NAME-$NAME-$VERSION"
cd $direname
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

CFLAGS+="-O2 -fPIC -ffat-lto-objects"
CXXFLAGS+="-O2 -fPIC -ffat-lto-objects"

./configure "${configure_options[@]}"
make -j$(nproc)
sudo make install
cd ..
rm -rf ${filename} $direname
