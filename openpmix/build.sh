#!/bin/bash
set -e
# Variable declarations
name=openpmix
__name=pmix
version=$(wget -cqO- https://github.com/openpmix/openpmix/releases | grep "/releases/tag/v" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6 | sed 's/^v//g')
filename="$__name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(
  hwloc
)
lfs_depends=(bash bzip2 coreutils make perl python sed tar zlib)
blfs_depends=(libevent)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/openpmix/openpmix/releases/download/v$version/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
./autogen.pl
local configure_options=(
    --prefix=/usr
    --sysconfdir=/etc/$name
  )

# set environment variables for reproducible build
# see https://docs.openpmix.org/en/latest/release-notes/general.html
export HOSTNAME=buildhost
export USER=builduser
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./configure "${configure_options[@]}"
# prevent excessive overlinking due to libtool
sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
make V=1 -j$(nproc)
sudo make install
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/lfs-custom-packages/$name
