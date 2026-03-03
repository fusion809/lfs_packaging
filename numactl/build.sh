#!/bin/bash
set -e
depends=()
lfs_depends=(autoconf bash coreutils glibc gzip make sed tar)
blfs_depends=(wget)
name=numactl
version=$(wget -cqO- https://github.com/numactl/numactl/releases | grep "releases/tag/v[0-9]" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6 | sed 's/^v//g')
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/numactl/numactl/archive/v$version.tar.gz -O $name-$version.tar.gz
fi
rm -rf $direname
tar xf $filename
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
cd ..
sudo rm -rf $direname $filename
echo $version > /var/lib/lfs-custom-packages/$name
