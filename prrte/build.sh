#!/bin/bash
set -e
# Variable declarations
name=prrte
version=$(gh_ver "openpmix/prrte")
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(hwloc openpmix)
lfs_depends=(bash coreutils glibc gzip make perl sed systemd tar)
blfs_depends=(libevent libnl wget)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/openpmix/prrte/releases/download/v$version/$name-$version.tar.gz
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
./autogen.pl
configure_options=(
    --prefix=/usr
    --sysconfdir=/etc/$name
)

# set environment variables for reproducible build
# see https://docs.prrte.org/en/latest/release-notes.html
export HOSTNAME=buildhost
export USER=builduser
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./configure "${configure_options[@]}"
# prevent excessive overlinking due to libtool
sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
maki V=1
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name