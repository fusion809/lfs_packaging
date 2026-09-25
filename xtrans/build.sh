#!/bin/bash
set -e
# Variable declarations
name=xtrans
homepage="https://gitlab.freedesktop.org/xorg/lib/libxtrans"
version=$(xfd_ver $name)
direname="$name-$version"
filename="$direname.tar.xz"
depends=(bash coreutils fontconfig glibc libxcb make sed systemd tar util-linux xorg-libs xz zlib)
# Fetch and unpack source
xfd_download "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
XORG_CONFIG="--prefix=/usr"
docdir="--docdir=/usr/share/doc/$packagedir"
cmi $XORG_CONFIG $docdir
cd ..
sudo rm -rf $direname $filename
sudo /sbin/ldconfig
echo $version | sudo tee /var/lib/custom-packages/$name
