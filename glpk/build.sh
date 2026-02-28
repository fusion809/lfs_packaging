#!/bin/bash
set -e
depends=()
NAME=glpk
VERSION=$(wget -cqO- https://ftp.gnu.org/gnu/glpk/ | grep ".tar.gz\"" | cut -d '"' -f 8 | tail -n 1 | sed 's/glpk-//g' | sed 's/.tar.gz//g')
filename="$NAME-$VERSION.tar.gz"
if ! [[ -f $filename ]]; then
	wget -c https://ftp.gnu.org/gnu/glpk/$filename
fi
if ! [[ -f gcc-15.patch ]]; then
	wget -c "https://gitlab.archlinux.org/archlinux/packaging/packages/glpk/-/raw/main/gcc-15.patch?ref_type=heads&inline=false" -O gcc-15.patch
fi
tar xf $filename
direname=${filename/.tar.gz/}
rm -rf $direname
tar xf $filename
cd $direname
patch -Np1 -i ../gcc-15.patch
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
autoreconf -fiv
./configure --prefix=/usr --with-gmp
make -j$(nproc)
sudo make install
cd ..
rm -rf $filename $direname
