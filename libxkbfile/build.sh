#!/bin/bash
set -e
# Variable declarations
name=libxkbfile
version=$(xfd_ver $name)
direname="${name}-$version"
filename="$direname.tar.xz"
lfs_depends=(bash coreutils glibc sed systemd tar util-linux xz zlib meson)
depends=(libX11)
blfs_depends=(fontconfig libXau libXdmcp libxcb xorg-libs)
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
mni $XORG_CONFIG --buildtype=release
cd ../..
sudo rm -rf $direname $filename
sudo /sbin/ldconfig
echo $version > /var/lib/custom-packages/$name
