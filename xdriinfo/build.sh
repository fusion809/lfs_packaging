#!/bin/bash
set -e
# Variable declarations
name=xdriinfo
version=$(xfd_ver $name)
direname="${name}-$version"
filename="$direname.tar.xz"
depends=(bash bzip2 coreutils expat fontconfig gcc glibc libdrm libelf libffi libpciaccess libpng libX11 libXau libxcb libXdmcp libXext libxml2 libxshmfence libXxf86vm llvm lm-sensors make mesa mesa sed spirv-tools systemd tar util-linux xbitmaps xcb-util xorg-libs xz zlib zstd)
# Fetch and unpack source

    xfd_download "$name" "$filename"
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
