#!/bin/bash
if ! [[ -d "wl-clipboard" ]]; then
	git clone https://github.com/bugaevc/wl-clipboard
fi

cd wl-clipboard
git pull origin master
mkdir build
cd build
meson setup --prefix=/usr       \
            --buildtype=release \
	    ..
ninja -j$(nproc)
sudo ninja install
