#!/bin/bash
set -e
# Variable declarations
name=gcab
version=$(gn_ver $name)
direname="$name-$version"
filename="$direname.tar.xz"
depends=()
lfs_depends=(bash coreutils gcc glibc meson ninja sed tar xz)
blfs_depends=(glib gtk-doc vala)
# Fetch and unpack source
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/gcab/$version/$filename
fi
tar xf $filename
cd $direname
# Compile and install
mkdir build
cd build
  CFLAGS="-O2 -fPIC"
  CXXFLAGS="-O2 -fPIC"
  meson setup .. \
    --buildtype=release \
    --infodir=/usr/info \
    --libdir=/usr/lib \
    --localstatedir=/var \
    --mandir=/usr/man \
    --prefix=/usr \
    --sysconfdir=/etc \
    -Dstrip=true
  "${NINJA:=ninja}"
  DESTDIR=/ sudo $NINJA install
cd ..

sudo rm -f /usr/lib*/*.la

sudo mkdir -p /usr/share/doc/$direname
sudo cp -a \
   COPYING NEWS README.md RELEASE \
   /usr/share/doc/$direname
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
