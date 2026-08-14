#!/bin/bash
set -e
# Variable declarations
name=libfabric
source ~/lfs_packaging/shared-funcs.sh
version=$(gh_ver "ofiwg/libfabric")
filename="$name-$version.tar.bz2"
direname=${filename/.tar.bz2/}
depends=(numactl)
lfs_depends=(autoconf bash bzip2 coreutils glibc make sed tar)
blfs_depends=(wget)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/ofiwg/libfabric/releases/download/v$version/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
autoreconf -fvi
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./configure --prefix=/usr
sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
make -j$(nproc)
sudo make install
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
