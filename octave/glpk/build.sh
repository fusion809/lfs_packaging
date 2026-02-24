#!/bin/bash
NAME=glpk
VERSION=$(wget -cqO- https://ftp.gnu.org/gnu/glpk/ | grep ".tar.gz\"" | cut -d '"' -f 8 | tail -n 1 | sed 's/glpk-//g' | sed 's/.tar.gz//g')
if ! [[ -f $NAME-$VERSION.tar.gz ]]; then
	wget -c https://ftp.gnu.org/gnu/glpk/$NAME-$VERSION.tar.gz
fi
wget -c "https://gitlab.archlinux.org/archlinux/packaging/packages/glpk/-/raw/main/gcc-15.patch?ref_type=heads&inline=false" -O gcc-15.patch
tar xf $NAME-$VERSION.tar.gz
cd $NAME-$VERSION
patch -Np1 -i ../gcc-15.patch
autoreconf -fiv
./configure --prefix=/usr --with-gmp
make -j$(nproc)
sudo make install
