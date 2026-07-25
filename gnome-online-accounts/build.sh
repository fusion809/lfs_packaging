#!/bin/bash
set -e
# Variable declaration
name=gnome-online-accounts
version="$(wget -cqO- https://gitlab.gnome.org/GNOME/gnome-online-accounts/-/tags | grep "tags/" | cut -d '/' -f 6 | sed 's/".*//g' | grep -v "alpha\|beta\|\.rc" | head -n 1 | sed 's/^v//g')"
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
blfs_depends=(dconf
	gsettings-desktop-schemas
	itstool
	libhandy
	vte
	gnome-shell
	nautilus)
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
	    -D man=false \
	    ..
ninja -j$(nproc)
sudo ninja install
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
