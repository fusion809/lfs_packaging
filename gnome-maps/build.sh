#!/bin/bash
set -e
# Variable declaration
name=gnome-maps
version="$(wget -cqO- https://gitlab.gnome.org/GNOME/gnome-maps/-/tags | grep "tags/" | cut -d '/' -f 6 | sed 's/".*//g' | grep -v "alpha\|beta\|\.rc" | grep "$(gnome-shell --version | cut -d ' ' -f 3 | cut -d '.' -f 1)" | head -n 1 | sed 's/^v//g')"
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
lfs_depends=(glibc
	gcc
	systemd
	zlib)
blfs_depends=(blueprint-compiler
	desktop-file-utils
	geoclue
	geocode-glib
	gjs
	libadwaita
	libgweather
	libportal
	librest
	libshumate)
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
cd ..
sudo rm -rf $name-$version*
echo $version > /var/lib/custom-packages/$name
