#!/bin/bash
set -e
# Variable declarations
name=spice-protocol
version=$(spice_ver $name)
docs="COPYING *.md"
direname="$name-$version"
filename="$direname.tar.xz"
depends=()
lfs_depends=(bash coreutils meson ninja sed tar)
blfs_depends=(wget)
# Fetch and unpack source
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://www.spice-space.org/download/releases/$filename
fi
tar xvf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
mkdir meson-build
cd meson-build
meson setup \
  --prefix=/usr \
  --libdir=lib \
  --libexecdir=/usr/libexec \
  --bindir=/usr/bin \
  --sbindir=/usr/sbin \
  --includedir=/usr/include \
  --datadir=/usr/share \
  --mandir=/usr/man \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --buildtype=release \
  .. || exit 1
  "${NINJA:=ninja}" || exit 1
  DESTDIR=/ sudo $NINJA install || exit 1
cd ..
sudo mkdir -p /usr/share/doc/$direname
sudo cp -a $docs /usr/share/doc/$direname
# Cleanup and add to database
cd ..
rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
