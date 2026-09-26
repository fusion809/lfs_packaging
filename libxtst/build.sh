#!/bin/bash
set -e
# Variable declarations
_name=libXtst
name=$(echo $_name | tr '[:upper:]' '[:lower:]')
homepage="https://gitlab.freedesktop.org/xorg/lib/libxtst"
description="library for XTEST & RECORD extensions"
version=$(xfd_ver $_name)
direname="${_name}-$version"
filename="$direname.tar.xz"
depends=(bash coreutils fontconfig glibc libx11 libxau libxcb libxdmcp libxext libxi make sed systemd tar util-linux xorg-libs xz zlib)
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
