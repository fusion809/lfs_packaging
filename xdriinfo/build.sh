#!/bin/bash
set -e
# Variable declarations
name=xdriinfo
version=$(xfd_ver $name)
direname="${name}-$version"
filename="$direname.tar.xz"
lfs_depends=(bash bzip2 coreutils expat gcc glibc libelf libffi make sed systemd tar util-linux xz zlib zstd)
depends=(libX11 libXext libXxf86vm libpciaccess libxshmfence mesa)
blfs_depends=(fontconfig libXau libXdmcp libdrm libpng libxcb libxml2 llvm lm-sensors mesa spirv-tools xbitmaps xcb-util xorg-libs)
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
cmi $XORG_CONFIG
cd ..
sudo rm -rf $direname $filename
sudo rm -f /usr/bin/xkeystone
echo $version > /var/lib/custom-packages/$name
