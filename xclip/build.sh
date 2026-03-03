#!/bin/bash
set -e
# Variable declarations
name=xclip
depends=()
lfs_depends=(autoconf bash coreutils make)
blfs_depends=(git libxmu # Xorg library
)
# Fetch source
if ! [[ -d $name ]]; then
	git clone https://github.com/astrand/xclip
fi
cd $name
git pull origin master
version=$(git log | head -n 1 | cut -d ' ' -f 2)
# Compile and install
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
autoreconf
./configure --prefix=/usr
make -j$(nproc)
sudo make install
sudo make install.man
# Add to database
echo $version > /var/lib/lfs-custom-packages/$name