#!/bin/bash
set -e
depends=(hwloc openpmix)
lfs_depends=(bash coreutils glibc gzip make perl sed tar)
blfs_depends=(libevent wget)
name=prrte
version=$(wget -cqO- https://github.com/openpmix/prrte/releases | grep -v "alpha\|beta\|rc" | grep "releases/tag/v" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6 | sed 's/^v//g')
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/openpmix/prrte/releases/download/v$version/$name-$version.tar.gz
fi
tar xf $filename
cd $direname
./autogen.pl
configure_options=(
    --prefix=/usr
    --sysconfdir=/etc/$name
)

# set environment variables for reproducible build
# see https://docs.prrte.org/en/latest/release-notes.html
export HOSTname=buildhost
export USER=builduser
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./configure "${configure_options[@]}"
# prevent excessive overlinking due to libtool
sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
make V=1 -j$(nproc)
sudo make install
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/lfs-custom-packages/$name