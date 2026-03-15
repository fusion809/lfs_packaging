#!/bin/bash
set -e
# Variable declarations
name=hwloc
version=$(wget -cqO- https://github.com/open-mpi/hwloc/releases | grep "/tag/hwloc-" | head -n 1 | cut -d '/' -f 6 | cut -d '"' -f 1 | cut -d '-' -f 2)
filename="$name-$version.tar.bz2"
direname=${filename/.tar.bz2/}
depends=(libpciaccess)
lfs_depends=(bash bzip2 coreutils glibc libtool make ncurses systemd sed tar)
blfs_depends=(wget)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/open-mpi/hwloc/releases/download/hwloc-$version/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./configure \
    --prefix=/usr \
    --sbindir=/usr/bin \
    --enable-plugins \
    --sysconfdir=/etc
make -j$(nproc)
sudo make install
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
