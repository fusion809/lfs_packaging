#!/bin/bash
set -e
# Variable declarations
name=libaec
version=$(wget -cqO- https://gitlab.dkrz.de/dkrz-sw/libaec/-/tags | grep 'tags/v' | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 2 | cut -d '/' -f 6 | sed 's/v//g')
filename="$name-v$version.tar.bz2"
direname=${filename/.tar.bz2/}
depends=()
lfs_depends=(bash bzip2 coreutils glibc sed tar)
blfs_depends=(cmake wget)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.dkrz.de/k202009/libaec/-/archive/v$version/$name-v$version.tar.bz2
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
cmake -B build -S . \
    -DCMAKE_BUILD_TYPE=None \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -Wno-dev \
    -DBUILD_STATIC_LIBS=OFF
cmake --build build
sudo cmake --install build
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/lfs-custom-packages/$name
