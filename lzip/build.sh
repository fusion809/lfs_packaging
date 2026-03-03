#!/bin/bash
set -e
# Variable declarations
name=lzip
version=$(wget -cqO- https://download.savannah.gnu.org/releases/lzip/ | grep "lzip-[0-9.]*.tar.gz\"" | grep -v "alpha\|beta\|rc" | tail -n 1 | cut -d '"' -f 4 | sed 's/lzip-//g' | sed 's/.tar.gz//g')
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=()
lfs_depends=(bash coreutils glibc gcc gzip make sed tar)
blfs_depends=(wget)
src="https://download.savannah.gnu.org/releases/$name/$filename"
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c $src
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./configure --prefix=/usr
make -j$(nproc)
sudo make install
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/lfs-custom-packages/$name
