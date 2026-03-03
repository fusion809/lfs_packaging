#!/bin/bash
set -e
# Variable declarations
name=libpciaccess
version=$(wget -cqO- https://xorg.freedesktop.org/releases/individual/lib/ | grep "libpciaccess.*xz\"" | grep -v "alpha\|beta\|rc" | cut -d '"' -f 2 | cut -d '-' -f 2 | sed 's/.tar.xz//g' | sort -V | tail -n 1)
filename="$name-$version.tar.xz"
direname=${filename/.tar.xz/}
depends=()
lfs_depends=(bash coreutils glibc make meson ninja sed tar xz zlib)
blfs_depends=(util-macros wget)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://xorg.freedesktop.org/releases/individual/lib/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
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
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version > /var/lib/lfs-custom-packages/$name