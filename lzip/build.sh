#!/bin/bash
set -e
# Variable declarations
name=lzip
version=$(wget -cqO- https://download.savannah.gnu.org/releases/lzip/ | grep -oE 'lzip-[0-9.]+\.tar\.gz' | sort -V | tail -n 1 | sed -e 's/lzip-//' -e 's/.tar.gz//')
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
export DDIR=/tmp/custom_stagedir
mkdir -p $DDIR
make install DESTDIR="$DDIR" || true
sudo make install
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
if [ -d "$DDIR" ] && [ "$(ls -A "$DDIR" 2>/dev/null)" ]; then
   find "$DDIR" -mindepth 1 | sed "s|^$DDIR||" | sudo tee -a "/var/lib/custom-packages/$name" > /dev/null
fi
sudo rm -rf $DDIR
