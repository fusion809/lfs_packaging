#!/bin/bash
set -e
# Variable declaration
name=eog
version=$(gn_ver $name)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
lfs_depends=(glibc
	gcc
	systemd
	zlib)
blfs_depends=(cairo
	dconf
	exempi
	gdk-pixbuf
	glib
	gnome-desktop
	gtk3
	hicolor-icon-theme
	lcms
	libexif
	libhandy
	libjpeg-turbo
	libpeas
	librsvg
	libx11
	meson)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.gnome.org/GNOME/$name/-/archive/$version/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
mkdir build
cd build
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
meson setup --prefix=/usr       \
            --buildtype=release \
	    ..
ninja -j$(nproc)
sudo ninja install
# Cleanup and add to database
cd ../..
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
