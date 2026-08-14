#!/bin/bash
set -e
# Variable declaration
name=libgusb
version=$(gh_ver "hughsie/libgusb")
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
blfs_depends=(json-glib
	libusb
	glib2
	hwdata
	vala)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c https://github.com/hughsie/libgusb/releases/download/$version/$filename
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
	    -D docs=false \
	    ..
ninja -j$(nproc)
sudo ninja install
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
