#!/bin/bash
set -e
# Variable declarations
name=orc
version=$(wget -cqO- https://gstreamer.freedesktop.org/src/orc/ | grep ".tar.xz\"" | grep -v "alpha\|beta\|\.rc" | cut -d '"' -f 2 | sed 's/.tar.xz//g' | cut -d '-' -f 2 | tail -n 1)
direname="$name-$version"
filename="$direname.tar.xz"
depends=()
lfs_depends=(bash coreutils meson ninja pkgconf sed tar xz)
blfs_depends=(wget)
optional_depends=(libcacard) # Provides smartcard support
docs="CONTRIBUTING.md COPYING README RELEASE ROADMAP.md"
# check if libcacard is there
if pkg-config --exists libcacard ; then
  with_cacard="--enable-smartcard"
else
  with_cacard="--disable-smartcard"
fi
# Fetch and unpack source
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c http://gstreamer.freedesktop.org/src/$name/$filename
fi
tar xvf $filename
# Compile and install
cd $direname
mkdir build &&
cd    build &&
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
meson setup --prefix=/usr --buildtype=release .. &&
ninja
sudo ninja install
cd ..
sudo mkdir -p /usr/share/doc/$direname
for i in $docs
do
	sudo cp -a $i /usr/share/doc/$direname
done
sudo rm -f /usr/lib*/*.la
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
