#!/bin/bash
set -e
depends=()
lfs_depends=(bash coreutils glibc gzip make sed tar)
blfs_depends=(giflib libjpeg-turbo libpng libtiff libwebp openjpeg wget)
name="leptonica"
version=$(wget -cqO- https://github.com/DanBloomberg/leptonica/releases | grep "/tag/" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6)
filename="$name-$version.tar.gz"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/DanBloomberg/leptonica/archive/ref/tags/${version}.tar.gz -O $filename
fi
rm -rf ${filename/.tar.gz/}
tar xf $filename
cd ${filename/.tar.gz/}
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./autogen.sh --prefix=/usr
./configure --prefix=/usr
make -j$(nproc)
sudo make install
cd ..
sudo rm -rf ${filename/.tar.gz/} $filename
echo $version > /var/lib/lfs-custom-packages/$name
