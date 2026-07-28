#!/bin/bash
set -e
# Variable declaration
name=zenity
version="$(wget -cqO- https://gitlab.gnome.org/GNOME/zenity/-/tags | grep "tags/" | cut -d '/' -f 6 | sed 's/".*//g' | grep -v "alpha\|beta\|\.rc" | head -n 1 | sed 's/^v//g')"
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
lfs_depends=(glibc
	gcc
	systemd
	zlib util-linux)
blfs_depends=(glib2 gtk4 hicolor-icon-theme libadwaita pango git meson)
# Fetch source and unpack it
if ! [[ -d $name ]]; then
	git clone https://gitlab.gnome.org/GNOME/$name
fi

# Compile and install
cd $name
git checkout $version
rm -rf build
mkdir build
cd build
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
meson setup --prefix=/usr       \
            --buildtype=release \
	    -D manpage=false \
	    ..
ninja -j$(nproc)
sudo ninja install
# Cleanup and add to database
cd ../..
echo $version > /var/lib/custom-packages/$name
