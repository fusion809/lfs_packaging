#!/bin/bash
set -e
# Variable declaration
name=libadwaita
version=$(git ls-remote --tags --refs https://gitlab.gnome.org/GNOME/libadwaita.git | grep -v "beta\|alpha\|rc" | tail -n 1 | cut -d '/' -f 3)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
lfs_depends=(glibc
	gcc
	systemd
	zlib)
blfs_depends=(gtk4 sassc vala)
depends=(appstream)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/libadwaita/$(echo $version | sed 's/.[0-9]$//g')/$filename
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
