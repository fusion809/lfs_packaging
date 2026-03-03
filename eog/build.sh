#!/bin/bash
set -e
depends=()
lfs_depends=(bash bzip2 coreutils gcc glibc meson ninja sed systemd tar zlib)
blfs_depends=(cairo dconf exempi gdk-pixbuf glib gnome-desktop gtk3 hicolor-icon-theme littlecms libexif libhandy libjpeg-turbo libpeas libpng librsvg libtiff libx11 # Xorg lib
libxml2 pango)
NAME=eog
VERSION="$(wget -cqO- https://gitlab.gnome.org/GNOME/eog/-/tags | grep "tags/" | cut -d '/' -f 6 | sed 's/".*//g' | grep -v "alpha\|beta\|rc" | head -n 1 | sed 's/^v//g')"
filename="$NAME-$VERSION.tar.bz2"
wget -c https://gitlab.gnome.org/GNOME/$NAME/-/archive/$VERSION/$filename
tar xf $filename
cd ${filename/.tar.bz2/}
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
sudo rm -rf $NAME-$VERSION*
echo $VERSION > /var/lib/lfs-custom-packages/$NAME
