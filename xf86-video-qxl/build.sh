#!/bin/bash

# Originally a Slackware build script for spice
# Brenton Horne maintains it as LFS build script

# Originally maintained by 2013-2025 Matteo Bernardini <ponce@slackbuilds.org>, Pisa, Italy
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

set -e
depends=(spice spice-protocol)
lfs_depends=(bash coreutils glibc make sed systemd tar xz)
blfs_depends=(libxfont2 # Xorg library
wget xorgproto xorg-server)
optional_depends=(libcacard) # Smartcard uspport
name=xf86-video-qxl
version=$(wget -cqO- https://xorg.freedesktop.org/releases/individual/driver/ | grep "xf86-video-qxl.*.tar.xz\"" | grep -v "alpha\|beta\|rc" | cut -d '"' -f 2 | head -n 1 | sed 's/xf86-video-qxl-//g' | sed 's/.tar.xz//g')

if [ "${XSPICE:-no}" = "yes" ]; then
  with_xspice="--enable-xspice=yes"
else
  with_xspice=""
fi

direname="$name-$version"
rm -rf $direname
filename="$direname.tar.xz"
if ! [[ -f $filename ]]; then
	wget -c https://xorg.freedesktop.org/releases/individual/driver/$filename
fi
tar xvf $filename
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
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/lfs-custom-packages/$name