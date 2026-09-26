#!/bin/bash
set -e
# Variable declarations
name=xf86-video-qxl
homepage="https://www.x.org"
description="Xorg X11 qxl video driver"
version=$(xfd_ver $name)
if [ "${XSPICE:-no}" = "yes" ]; then
  with_xspice="--enable-xspice=yes"
else
  with_xspice=""
fi
direname="$name-$version"
filename="$direname.tar.xz"
depends=(bash coreutils glibc make sed spice spice-protocol systemd tar wget xorgproto xorg-server xz)
optional_depends=(libcacard) # Smartcard support
# Fetch and unpack source
xfd_download "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
patch -p1 < ../libdrm.patch
# autogen.sh can be used in place of configure
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
configure_options=(
  --prefix=/usr \
  --libdir=/usr/lib \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --mandir=/usr/man \
  --docdir=/usr/share/doc/$direname \
  $with_xspice
)
cmi "${configure_options[@]}"

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
echo $version | sudo tee /var/lib/custom-packages/$name
