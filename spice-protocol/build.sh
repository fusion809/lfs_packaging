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
depends=()
NAME=spice-protocol
VERSION=$(wget -cqO- https://spice-space.org/download/releases/ | grep "spice-protocol-.*xz\"" | grep -v "alpha\|beta\|rc" | cut -d '"' -f 8  | tail -n 1 | cut -d '-' -f 3 | sed 's/.tar.xz//g')
ARCH=noarch

DOCS="COPYING *.md"
direname="$NAME-$VERSION"
filename="$direname.tar.xz"
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://www.spice-space.org/download/releases/$filename
fi
tar xvf $filename
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
sudo cp -a $DOCS /usr/share/doc/$direname
cd ..
rm -rf $direname $filename
echo $VERSION > /var/lib/lfs-custom-packages/$NAME