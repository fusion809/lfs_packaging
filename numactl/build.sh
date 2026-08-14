#!/bin/bash
set -e
# Variable declarations
name=numactl
version=$(gh_ver "numactl/numactl")
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=()
lfs_depends=(autoconf bash coreutils glibc gzip make sed tar)
blfs_depends=(wget)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/numactl/numactl/archive/v$version.tar.gz -O $filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
autoreconf -fiv
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./configure --prefix=/usr
# prevent excessive overlinking due to libtool
sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
make -j$(nproc)
sudo make install
sudo install -vDm 644 README.md -t "/usr/share/doc/$direname/"
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
