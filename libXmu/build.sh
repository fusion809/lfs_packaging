#!/bin/bash
set -e
# Variable declarations
name=libXmu
version=$(xfd_ver $name)
direname="${name}-$version"
filename="$direname.tar.xz"
depends=(bash coreutils fontconfig glibc libICE libSM libX11 libXau libxcb libXdmcp libXext libXt make sed systemd tar util-linux xorg-libs xz zlib)
# Fetch and unpack source
xfd_download "$name" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
XORG_CONFIG="--prefix=/usr"
docdir="--docdir=/usr/share/doc/$packagedir"
cmi $XORG_CONFIG $docdir
cd ..
sudo rm -rf $direname $filename
sudo /sbin/ldconfig
echo $version | sudo tee /var/lib/custom-packages/$name
