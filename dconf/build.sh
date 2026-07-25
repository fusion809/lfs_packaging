#!/bin/bash
set -e
# Variable declaration
name=dconf
function pkgver {
	wget -cqO- https://gitlab.gnome.org/GNOME/$1/-/tags | grep "tags/" | cut -d '/' -f 6 | sed 's/".*//g' | grep -v "alpha\|beta\|\.rc" | head -n 1 | sed 's/^v//g'
}
version="$(pkgver $name)"
edVersion="$(pkgver $name-editor)"
filename="$name-$version.tar.xz"
edFilename="$name-editor-$edVersion.tar.xz"
direname="${filename/.tar.xz/}"
edDirename="${edFilename/.tar.xz/}"
blfs_depends=(dconf
	gsettings-desktop-schemas
	itstool
	libhandy
	vte
	gnome-shell
	nautilus)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/dconf/$(echo "${version}" | sed 's/.[0-9]$//g')/$filename
fi

if ! [[ -f $edFilename ]]; then
	wget -c https://download.gnome.org/sources/dconf-editor/$(echo $edVersion | sed 's/.[0-9]$//g')/$edFilename
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
cd ..              &&
tar -xf ../$edFilename &&
cd $edDirename                &&

mkdir build &&
cd    build &&

meson setup --prefix=/usr --buildtype=release .. &&
ninja -j$(nproc)
sudo ninja install
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename $edFilename
echo $version > /var/lib/custom-packages/$name
