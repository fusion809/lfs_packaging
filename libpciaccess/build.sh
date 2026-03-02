#!/bin/bash
set -e
NAME=libpciaccess
VERSION=$(wget -cqO- https://xorg.freedesktop.org/releases/individual/lib/ | grep "libpciaccess.*xz\"" | grep -v "alpha\|beta\|rc" | cut -d '"' -f 2 | cut -d '-' -f 2 | sed 's/.tar.xz//g' | sort -V | tail -n 1)
filename="$NAME-$VERSION.tar.xz"
if ! [[ -f $filename ]]; then
	wget -c https://xorg.freedesktop.org/releases/individual/lib/$filename
fi
direname=${filename/.tar.xz/}
rm -rf $direname
tar xf $filename
cd $direname
mkdir build
cd build
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
meson setup --prefix=/usr       \
            --buildtype=release \
	    ..
ninja -j$(nproc)
sudo ninja install
cd ..
sudo rm -rf $direname $filename
echo $VERSION > /var/lib/lfs-custom-packages/$NAME