#!/bin/bash
set -e
# Variable declarations
name="leptonica"
source ~/lfs_packaging/shared-funcs.sh
version=$(gh_ver "DanBloomberg/leptonica")
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=()
lfs_depends=(bash coreutils glibc gzip make sed tar)
blfs_depends=(giflib libjpeg-turbo libpng libtiff libwebp openjpeg wget)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/DanBloomberg/leptonica/archive/${version}.tar.gz -O $filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./autogen.sh --prefix=/usr
./configure --prefix=/usr
make -j$(nproc)
sudo make install
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
