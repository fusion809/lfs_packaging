#!/bin/bash
set -e
# Variable declarations
name=libXft
version=$(xfd_ver $name)
direname="${name}-$version"
filename="$direname.tar.xz"
lfs_depends=(bash bzip2 coreutils expat glibc make sed systemd tar util-linux xz zlib)
depends=(libX11 libXrender)
blfs_depends=(brotli fontconfig freetype libXau libXdmcp libpng libxcb xorg-libs)
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
cd ..
sudo rm -rf $direname $filename
sudo /sbin/ldconfig
echo $version > /var/lib/custom-packages/$name
