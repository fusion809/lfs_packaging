#!/bin/bash
set -e
# Variable declaration
name=libhandy
version="$(wget -cqO- https://gitlab.gnome.org/GNOME/$name/-/tags | grep "tags/" | cut -d '/' -f 6 | sed 's/".*//g' | grep -v "alpha\|beta\|\.rc" | head -n 1 | sed 's/^v//g')"
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
blfs_depends=(gtk3 vala)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/$name/$(echo $version | sed 's/.[0-9]$//g')/$filename
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
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
