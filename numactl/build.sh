#!/bin/bash
set -e
depends=()
NAME=numactl
VERSION=$(wget -cqO- https://github.com/numactl/numactl/releases | grep "releases/tag/v[0-9]" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6 | sed 's/^v//g')
filename="$NAME-$VERSION.tar.gz"
direname="${filename/.tar.gz/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/numactl/numactl/archive/v$VERSION.tar.gz -O $NAME-$VERSION.tar.gz
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
echo $VERSION > /var/lib/lfs-custom-packages/$NAME
