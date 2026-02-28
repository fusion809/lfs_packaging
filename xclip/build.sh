#!/bin/bash
set -e
NAME=xclip
VERSION=$(wget -cqO- https://github.com/astrand/xclip/commit/master | grep "clip@" | head -n 1 | sed 's/.* · astrand\/xclip@//g' | sed 's/ · GitHub<\/title>//g')

if ! [[ -d xclip ]]; then
	git clone https://github.com/astrand/xclip
fi

cd xclip
git pull origin master
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
autoreconf
./configure --prefix=/usr
make -j$(nproc)
sudo make install
sudo make install.man
