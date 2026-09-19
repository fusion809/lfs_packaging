#!/bin/bash
set -e
# Variable declarations
name=numactl
repo=numactl/numactl
version=$(gh_ver "$repo")
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(autoconf bash coreutils gcc glibc gzip make sed tar wget)
# Fetch and unpack source
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
sudo autoreconf -fiv
sudo chown $USER -R .
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./configure --prefix=/usr
# prevent excessive overlinking due to libtool
sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
maki
sudo install -vDm 644 README.md -t "/usr/share/doc/$direname/"
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
