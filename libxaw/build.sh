#!/bin/bash
set -e
# Variable declarations
_name=libXaw
name=$(echo $_name | tr '[:upper:]' '[:lower:]')
version=$(xfd_ver $_name)
direname="${_name}-$version"
filename="$direname.tar.xz"
depends=(bash coreutils fontconfig glibc libice libSM libx11 libxau libxcb libXdmcp libXext libXmu libXpm libxt make sed systemd tar util-linux xorg-libs xz zlib)
# Fetch and unpack source
xfd_download "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
XORG_CONFIG="--prefix=/usr"
docdir="--docdir=/usr/share/doc/$direname"
cmi $XORG_CONFIG $docdir
cd ..
sudo rm -rf $direname $filename
sudo /sbin/ldconfig
echo $version | sudo tee /var/lib/custom-packages/$name
