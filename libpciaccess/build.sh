#!/bin/bash
set -e
# Variable declarations
name=libpciaccess
homepage="https://gitlab.freedesktop.org/xorg/lib/libpciaccess"
description="X11 PCI access library"
version=$(xfd_ver $name)
filename="$name-$version.tar.xz"
direname=${filename/.tar.xz/}
depends=(bash coreutils glibc make meson ninja sed tar util-macros wget xz zlib)
# Fetch and unpack source
xfd_download "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
meson_options=(
	--prefix=/usr       \
	--libdir=/usr/lib   \
    --buildtype=release
)
mni "${meson_options[@]}"
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
