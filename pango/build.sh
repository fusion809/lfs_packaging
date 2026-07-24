#!/bin/bash
set -e
name=pango
version="$(wget -cqO- https://gitlab.gnome.org/GNOME/$name/-/tags | grep "tags/" | cut -d '/' -f 6 | sed 's/".*//g' | grep -v "alpha\|beta\|\.rc" | grep -v "1.90" | head -n 1 | sed 's/^v//g')"
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
blfs_depends=(fontconfig harfbuzz freetype fribidi glib2 cairo)
depends=(xorg-libs)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.gnome.org/GNOME/$name/-/archive/$version/$filename
fi
rm -rf "$direname"
tar xf $filename
# Compile and install
cd "$direname"
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
mkdir build &&
cd    build &&

meson setup --prefix=/usr            \
            --buildtype=release      \
            --wrap-mode=nofallback   \
            -D introspection=enabled \
            ..                       &&
ninja -j$(nproc)
sudo ninja install
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
