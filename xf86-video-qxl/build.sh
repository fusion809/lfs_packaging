#!/bin/bash
set -e
# Variable declarations
name=xf86-video-qxl
version=$(xfd_ver $name)
if [ "${XSPICE:-no}" = "yes" ]; then
  with_xspice="--enable-xspice=yes"
else
  with_xspice=""
fi
direname="$name-$version"
filename="$direname.tar.xz"
depends=(spice spice-protocol)
lfs_depends=(bash coreutils glibc make sed systemd tar xz)
blfs_depends=(libxfont2 # Xorg library
wget xorgproto xorg-server)
optional_depends=(libcacard) # Smartcard support
# Fetch and unpack source
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://xorg.freedesktop.org/releases/individual/driver/$filename
fi
tar xvf $filename
# Compile and install
cd $direname
patch -p1 < ../libdrm.patch

# autogen.sh can be used in place of configure
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./configure \
  --prefix=/usr \
  --libdir=/usr/lib \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --mandir=/usr/man \
  --docdir=/usr/share/doc/$direname \
  $with_xspice

make -j$(nproc)
sudo make install DESTDIR=/

# add a config file for Xorg and another one for Xspice (if needed)
sudo install -m 0644 -D ../05-qxl.conf \
  /usr/share/X11/xorg.conf.d/05-qxl.conf.new
sudo install -m 0644 -D examples/spiceqxl.xorg.conf.example \
    /etc/X11/spiceqxl.xorg.conf.new
sudo install -m 0755 -D scripts/Xspice /usr/bin/Xspice
sudo mkdir -p /usr/share/doc/$direname
sudo cp -a COPYING README* TODO* /usr/share/doc/$direname
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
