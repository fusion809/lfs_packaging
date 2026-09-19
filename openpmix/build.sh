#!/bin/bash
set -e
# Variable declarations
name=openpmix
_name=pmix
version=$(gh_ver $name/$name)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(bash bzip2 coreutils glibc libevent make perl python sed systemd tar zlib hwloc)
# Fetch and unpack source
ghr_download "openpmix/openpmix" "v$version" "$filename"
sudo rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
sudo ./autogen.pl
configure_options=(
    --prefix=/usr
    --sysconfdir=/etc/$name
  )

# set environment variables for reproducible build
# see https://docs.openpmix.org/en/latest/release-notes/general.html
export HOSTNAME=buildhost
export USER=builduser
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
sudo ./configure "${configure_options[@]}"
# prevent excessive overlinking due to libtool
sudo sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
sudo make V=1 -j$(nproc)
sudo make install
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
