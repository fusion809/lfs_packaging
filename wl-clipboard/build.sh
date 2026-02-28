#!/bin/bash
set -e
depends=()
NAME="wl-clipboard"
if ! [[ -d $NAME ]]; then
	git clone https://github.com/bugaevc/wl-clipboard
fi

cd $NAME
git pull origin master
VERSION=$(git log | head -n 1 | cut -d ' ' -f 2)
rm -rf build
mkdir build
cd build
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
meson setup --prefix=/usr       \
            --buildtype=release \
	    ..
ninja -j$(nproc)
sudo ninja install
cd ..
rm -rf build
cd ..
echo $VERSION > /var/lib/lfs-custom-packages/$NAME