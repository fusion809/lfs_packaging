#!/bin/bash
set -e
depends=()
lfs_depends=(bash coreutils glibc meson ninja)
blfs_depends=(git wayland wayland-protocols)
name="wl-clipboard"
if ! [[ -d $name ]]; then
	git clone https://github.com/bugaevc/wl-clipboard
fi

cd $name
git pull origin master
version=$(git log | head -n 1 | cut -d ' ' -f 2)
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
echo $version > /var/lib/lfs-custom-packages/$name