#!/bin/bash
NAME=eog
VERSION="$(wget -cqO- https://gitlab.gnome.org/GNOME/eog/-/tags | grep "tags/" | cut -d '/' -f 6 | sed 's/".*//g' | head -n 1 | sed 's/^v//g')"
wget -c https://gitlab.gnome.org/GNOME/$NAME/-/archive/$VERSION/$NAME-$VERSION.tar.bz2
tar xf $NAME-$VERSION.tar.bz2
cd $NAME-$VERSION
mkdir build
cd build
meson setup --prefix=/usr       \
            --buildtype=release \
	    ..
ninja -j$(nproc)
sudo ninja install
rm -rf $NAME-$VERSION
