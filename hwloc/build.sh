#!/bin/bash
set -e
depends=(libpciaccess)
lfs_depends=(bash bzip2 coreutils glibc libtool make ncurses systemd sed tar)
blfs_depends=(wget)
name=hwloc
version=$(wget -cqO- https://www.open-mpi.org/projects/hwloc/ | grep -i download | grep -v '>Download<' | grep -v "alpha\|beta\|rc" | cut -d '"' -f 2 | cut -d '/' -f 5 | sed 's/^v//g' | head -n 1)
filename="$name-$version.tar.bz2"
if ! [[ -f $filename ]]; then
	wget -c https://www.open-mpi.org/software/hwloc/v${version%.*}/downloads/$filename
fi
direname=${filename/.tar.bz2/}
rm -rf $direname
tar xf $filename
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
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/lfs-custom-packages/$name
