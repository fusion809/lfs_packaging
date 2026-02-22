#!/bin/bash

# Slackware build script for flatpak

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

cd $(dirname $0) ; CWD=$(pwd)

PRGNAM=flatpak
VERSION=${VERSION:-1.16.3}

if [ -z "$ARCH" ]; then
  case "$( uname -m )" in
    i?86) ARCH=i586 ;;
    arm*) ARCH=arm ;;
       *) ARCH=$( uname -m ) ;;
  esac
fi

# If the variable PRINT_PACKAGE_NAME is set, then this script will report what
# the name of the created package would be, and then exit. This information
# could be useful to other scripts.
if [ ! -z "${PRINT_PACKAGE_NAME}" ]; then
  echo "$PRGNAM-$VERSION-$ARCH-$BUILD$TAG.$PKGTYPE"
  exit 0
fi

# Abort build if architecture is not 64-bit.
if [ "$ARCH" != "x86_64" ]; then
  echo "$ARCH is not supported."
  exit 1
fi

set -e

rm -rf $PRGNAM-$VERSION
if ! [[ -f $PRGNAM-$VERSION.tar.xz ]]; then
	wget -c https://github.com/flatpak/flatpak/releases/download/${VERSION}/$PRGNAM-$VERSION.tar.xz
fi
tar xvf $CWD/$PRGNAM-$VERSION.tar.xz
cd $PRGNAM-$VERSION


mkdir build
cd build
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
    -Ddocdir=/usr/share/doc/$PRGNAM-$VERSION \
    -Dstrip=true
  "${NINJA:=ninja}" -j$(nproc)
  DESTDIR=/ sudo $NINJA install
cd ..

sudo chmod +x /etc/profile.d/flatpak.sh

sudo mkdir -p /usr/share/doc/$PRGNAM-$VERSION
sudo cp -a \
  COPYING NEWS \
  /usr/share/doc/$PRGNAM-$VERSION
