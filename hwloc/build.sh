#!/bin/bash
set -e
# Variable declarations
name=hwloc
version=$(gh_ver "open-mpi/hwloc")
filename="$name-$version.tar.bz2"
direname=${filename/.tar.bz2/}
depends=(libICE libSM libX11 libXext libXrender libpciaccess)
lfs_depends=(bash bzip2 coreutils expat gcc glibc libtool make ncurses sed systemd tar util-linux zlib)
blfs_depends=(brotli cairo fontconfig freetype libXau libXdmcp libpng libxcb libxml2 pixman wget)
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
