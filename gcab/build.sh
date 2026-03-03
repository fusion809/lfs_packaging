#!/bin/bash

# Maintained by Brenton Horne
# Originally a Slackware build script for "gcab".

# Copyright 2024 Andrew Payne <phalange@komputermatrix.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

set -e
depends=()
lfs_depends=(bash coreutils gcc glibc meson ninja sed tar xz)
blfs_depends=(glib gtk-doc vala)
NAME=gcab
VERSION=$(wget -cqO- https://download.gnome.org/sources/gcab/ | grep "[0-9]/" | grep -v "alpha\|beta\|rc" | cut -d '"' -f 4 | sed 's|/$||g' | tail -n 1)
direname="$NAME-$VERSION"
filename="$direname.tar.xz"
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/gcab/$VERSION/$filename
fi
tar xf $filename
cd $direname

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
cd ..
sudo rm -rf $direname $filename
echo $VERSION > /var/lib/lfs-custom-packages/$NAME
