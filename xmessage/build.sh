#!/bin/bash
set -e
# Variable declarations
name=xmessage
version=$(xfd_ver $name)
direname="${name}-$version"
filename="$direname.tar.xz"
lfs_depends=(bash coreutils glibc make sed systemd tar util-linux xz zlib)
depends=(libICE libSM libX11 libXaw libXext libXmu libXpm libXt)
blfs_depends=(fontconfig libXau libXdmcp libpng libxcb mesa xbitmaps xcb-util xorg-libs)
# Fetch and unpack source
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://xorg.freedesktop.org/archive/individual/app/$filename
fi
tar xvf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
XORG_CONFIG="--prefix=/usr"
./configure $XORG_CONFIG
make -j$(nproc)
sudo make install
cd ..
sudo rm -rf $direname $filename
sudo rm -f /usr/bin/xkeystone
echo $version > /var/lib/custom-packages/$name
