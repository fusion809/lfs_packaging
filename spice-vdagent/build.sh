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
depends=(libpciaccess spice-protocol)
NAME=spice-vdagent
VERSION=$(wget -cqO- https://spice-space.org/download/releases/ | grep "spice-vdagent.*.tar.bz2\"" | cut -d '"' -f 8 | tail -n 1 | cut -d '-' -f 3 | sed 's/.tar.bz2//g')
DOCS="COPYING CHANGELOG.md README.md"

direname="$NAME-$VERSION"
rm -rf $direname
filename="$direname.tar.bz2"
if ! [[ -f $filename ]]; then
	wget -c https://www.spice-space.org/download/releases/$filename
fi
tar xvf $filename
cd $direname

  # Set proper paths
  sed -i 's|/etc/sysconfig/spice-vdagentd|/etc/conf.d/spice-vdagentd|
' data/spice-vdagentd.service
  sed -i 's|/etc/sysconfig/spice-vdagentd|/etc/conf.d/spice-vdagentd|' data/spice-vdagentd.1.in
  sed -i 's/strstr(addr, "\/pci");/(char *)strstr(addr, "\/pci");/' src/vdagent/device-info.c
autoreconf -fi
export CFLAGS="-O2 -fPIC -Wno-error"
export CXXFLAGS="-O2 -fPIC -Wno-error"
./configure \
  --prefix=/usr \
  --libdir=/usr/lib \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --mandir=/usr/man \
  --with-init-script=systemd \
  --docdir=/usr/share/doc/$direname

make -j$(nproc)
sudo make install DESTDIR=/
cd ..
sudo rm -rf $direname $filename
# Install an init script and an X.org configuration file
sudo install -m 0644 -D 06-spice-vdagent.conf \
  /usr/share/X11/xorg.conf.d/06-spice-vdagent.conf.new

sudo mkdir -p /usr/share/doc/$direname
sudo cp -a $DOCS /usr/share/doc/$direname
echo $VERSION > /var/lib/lfs-custom-packages/$NAME