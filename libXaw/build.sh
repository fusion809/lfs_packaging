#!/bin/bash
set -e
# Variable declarations
name=libXaw
version=$(wget -cqO- https://xorg.freedesktop.org/archive/individual/lib/ | grep "$name" | grep '\.tar\.xz"' | tail -n 1 | cut -d '-' -f 2 | cut -d '"' -f 1 | sed 's/.tar.xz//g')
direname="${name}-$version"
filename="$direname.tar.xz"
lfs_depends=(bash coreutils glibc make sed systemd tar util-linux xz zlib)
blfs_depends=(libxcb fontconfig xorg-libs)
# Fetch and unpack source
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://xorg.freedesktop.org/archive/individual/lib/$filename
fi
tar xvf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
XORG_CONFIG="--prefix=/usr"
docdir="--docdir=/usr/share/doc/$packagedir"
./configure $XORG_CONFIG $docdir
make -j$(nproc)
sudo make install
sudo rm -rf $direname $filename
sudo /sbin/ldconfig
echo $version > /var/lib/custom-packages/$name
