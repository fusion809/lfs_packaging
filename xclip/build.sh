#!/bin/bash
set -e
NAME=xclip
depends=()
if ! [[ -d xclip ]]; then
	git clone https://github.com/astrand/xclip
fi

cd xclip
git pull origin master
VERSION=$(git log | head -n 1 | cut -d ' ' -f 2)
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
autoreconf
./configure --prefix=/usr
make -j$(nproc)
sudo make install
sudo make install.man
