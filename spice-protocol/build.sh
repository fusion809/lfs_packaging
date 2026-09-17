#!/bin/bash
set -e
# Variable declarations
name=spice-protocol
version=$(spice_ver $name)
docs="COPYING *.md"
direname="$name-$version"
filename="$direname.tar.xz"
depends=(bash coreutils meson ninja sed tar wget)
# Fetch and unpack source
spice_download "$name" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
meson_option=(
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
)
mni "${meson_options[@]}"
cd ..
sudo mkdir -p /usr/share/doc/$direname
sudo cp -a $docs /usr/share/doc/$direname
# Cleanup and add to database
cd ..
rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
