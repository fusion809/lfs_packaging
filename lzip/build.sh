#!/bin/bash
set -e
depends=()
lfs_depends=(bash coreutils glibc gcc gzip make sed tar)
blfs_depends=(wget)
name=lzip
version=$(wget -cqO- https://download.savannah.gnu.org/releases/lzip/ | grep "lzip-[0-9.]*.tar.gz\"" | grep -v "alpha\|beta\|rc" | tail -n 1 | cut -d '"' -f 4 | sed 's/lzip-//g' | sed 's/.tar.gz//g')
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
SRC="https://download.savannah.gnu.org/releases/$name/$filename"
if ! [[ -f "$name-$version.tar.gz" ]]; then
	wget -c $SRC
fi

tar xf $filename
cd $direname
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./configure --prefix=/usr
make -j$(nproc)
sudo make install
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/lfs-custom-packages/$name
