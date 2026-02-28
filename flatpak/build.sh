#!/bin/bash

# Maintained by Brenton Horne
# Originally a Slackware build script for flatpak

# Copyright 2020-2025 Andrew Payne <phalange@komputermatrix.com>
# Copyright 2017, 2018, 2019 Vincent Batts <vbatts@hashbangbash.com>
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
depends=(gcab ostree)
NAME=flatpak
VERSION=$(wget -cqO- https://github.com/flatpak/flatpak/releases/ | grep "/tag/" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6)
filename="$NAME-$VERSION.tar.xz"
direname=${filename/.tar.xz/}
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://github.com/flatpak/flatpak/releases/download/${VERSION}/$filename
fi
tar xvf $filename
cd $direname

mkdir build
cd build
  CFLAGS="-O2 -fPIC"
  CXXFLAGS="-O2 -fPIC"
  meson setup .. \
    --bindir=/usr/bin \
    --datadir=/usr/share \
    --includedir=/usr/include \
    --infodir=/usr/info \
    --libdir=/usr/lib \
    --libexecdir=/usr/libexec \
    --localstatedir=/var \
    --mandir=/usr/man \
    --prefix=/usr \
    --sbindir=/usr/sbin \
    --sysconfdir=/etc \
    -Ddocdir=/usr/share/doc/$NAME-$VERSION \
    -Dstrip=true
  "${NINJA:=ninja}" -j$(nproc)
  DESTDIR=/ sudo $NINJA install
cd ..

sudo chmod +x /etc/profile.d/flatpak.sh

sudo mkdir -p /usr/share/doc/$direname
sudo cp -a \
  COPYING NEWS \
  /usr/share/doc/$direname
cd ..
sudo rm -rf $filename $direname
echo $VERSION > /var/lib/lfs-custom-packages/$NAME
