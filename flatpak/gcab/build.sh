#!/bin/bash

# Slackware build script for "gcab".

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

cd $(dirname $0) ; CWD=$(pwd)

PRGNAM=gcab
VERSION=${VERSION:-1.6}

if [ -z "$ARCH" ]; then
  case "$( uname -m )" in
    i?86) ARCH=i586 ;;
    arm*) ARCH=arm ;;
       *) ARCH=$( uname -m ) ;;
  esac
fi

if [ ! -z "${PRINT_PACKAGE_NAME}" ]; then
  echo "$PRGNAM-$VERSION-$ARCH-$BUILD$TAG.$PKGTYPE"
  exit 0
fi

if [ "$ARCH" = "i586" ]; then
  SLKCFLAGS="-O2 -march=i586 -mtune=i686"
  LIBDIRSUFFIX=""
elif [ "$ARCH" = "i686" ]; then
  SLKCFLAGS="-O2 -march=i686 -mtune=i686"
  LIBDIRSUFFIX=""
elif [ "$ARCH" = "x86_64" ]; then
  SLKCFLAGS="-O2 -fPIC"
  LIBDIRSUFFIX=""
else
  SLKCFLAGS="-O2"
  LIBDIRSUFFIX=""
fi

set -e
rm -rf $PRGNAM-$VERSION
if ! [[ -f $PRGNAM-$VERSION.tar.xz ]]; then
	wget -c https://download.gnome.org/sources/gcab/$VERSION/$PRGNAM-$VERSION.tar.xz
fi
tar xf $CWD/$PRGNAM-$VERSION.tar.xz
cd $PRGNAM-$VERSION

mkdir build
cd build
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

sudo mkdir -p /usr/share/doc/$PRGNAM-$VERSION
sudo cp -a \
   COPYING NEWS README.md RELEASE \
   /usr/share/doc/$PRGNAM-$VERSION
