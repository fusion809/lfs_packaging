#!/bin/bash
set -e
# Variable declarations
name=xmodmap
version=$(xfd_ver $name)
direname="${name}-$version"
filename="$direname.tar.xz"
depends=(bash coreutils fontconfig glibc libpng libx11 libxau libxcb libxdmcp make mesa sed systemd tar util-linux xbitmaps xcb-util xorg-libs xz zlib)
# Fetch and unpack source
xfd_download "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
XORG_CONFIG="--prefix=/usr"
cmi $XORG_CONFIG
cd ..
sudo rm -rf $direname $filename
sudo rm -f /usr/bin/xkeystone
echo $version | sudo tee /var/lib/custom-packages/$name
