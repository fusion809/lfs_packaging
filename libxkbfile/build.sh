#!/bin/bash
set -e
# Variable declarations
name=libxkbfile
version=$(xfd_ver $name)
direname="${name}-$version"
filename="$direname.tar.xz"
lfs_depends=(bash coreutils glibc sed systemd tar util-linux xz zlib meson)
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
meson setup $XORG_CONFIG --buildtype=release build
ninja -C build
sudo ninja -C build install
cd ..
sudo rm -rf $direname $filename
sudo /sbin/ldconfig
echo $version > /var/lib/custom-packages/$name
