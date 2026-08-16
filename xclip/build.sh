#!/bin/bash
set -e
# Variable declarations
name=xclip
depends=(libICE libSM libX11 libXext libXmu libXt)
lfs_depends=(autoconf bash coreutils glibc make util-linux)
blfs_depends=(git libXau libXdmcp libxcb libxmu)
# Fetch source
if ! [[ -d $name ]]; then
	git clone https://github.com/astrand/xclip
fi
cd $name
version=$(git pull origin master -q && git log | head -n 1 | cut -d ' ' -f 2)
# Compile and install
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
autoreconf
./configure --prefix=/usr
make -j$(nproc)
sudo make install
sudo make install.man
# Add to database
echo $version > /var/lib/custom-packages/$name
