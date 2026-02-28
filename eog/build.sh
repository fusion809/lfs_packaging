#!/bin/bash
set -e
NAME=eog
VERSION="$(wget -cqO- https://gitlab.gnome.org/GNOME/eog/-/tags | grep "tags/" | cut -d '/' -f 6 | sed 's/".*//g' | head -n 1 | sed 's/^v//g')"
filename="$NAME-$VERSION.tar.bz2"
wget -c https://gitlab.gnome.org/GNOME/$NAME/-/archive/$VERSION/$filename
tar xf $filename
cd ${filename/.tar.bz2/}
mkdir build
cd build
meson setup --prefix=/usr       \
            --buildtype=release \
	    ..
ninja -j$(nproc)
sudo ninja install
cd ..
rm -rf $NAME-$VERSION*
