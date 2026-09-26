#!/bin/bash
set -e
# Variable declarations
_name=libXfont2
version=$(xfd_ver $_name)
direname="$_name-$version"
filename="$direname.tar.xz"
depends=(bash brotli bzip2 coreutils fontconfig freetype glibc libfontenc libpng libxcb make sed systemd tar util-linux xorg-libs xz zlib)
name=$(echo $_name | tr '[:upper:]' '[:lower:]')
homepage="https://xorg.freedesktop.org/"
description="X11 font rasterisation library"
# Fetch and unpack source
xfd_download "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
XORG_CONFIG="--prefix=/usr"
docdir="--docdir=/usr/share/doc/$direname"
cmi $XORG_CONFIG $docdir --disable-devel-docs
cd ..
sudo rm -rf $direname $filename
sudo /sbin/ldconfig
echo $version | sudo tee /var/lib/custom-packages/$name
