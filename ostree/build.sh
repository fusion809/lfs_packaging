#!/bin/bash

# Maintained by Brenton Horne
# Originally a Slackware build script for ostree

# Copyright 2019-2025 Andrew Payne <phalange@komputermatrix.com>
# Copyright 2017 Vincent Batts <vbatts@hashbangbash.com>
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
depends=(gcab)
lfs_depends=(bash coreutils glibc make python sed systemd tar util-linux xz zlib)
blfs_depends=(avahi curl e2fsprogs fuse glib gpgme gtk-doc libarchive libgpg-error libsoup libxslt openssl wget which)
NAME=ostree
VERSION=$(wget -cqO- https://github.com/ostreedev/ostree/releases | grep "/tag/" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6 | sed 's/^v//g')
direname="lib${NAME}-$VERSION"
filename="$direname.tar.xz"
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://github.com/ostreedev/ostree/releases/download/v${VERSION}/$filename
fi
tar xvf $filename
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./configure \
  --prefix=/usr \
  --libdir=/usr/lib \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --mandir=/usr/man \
  --docdir=/usr/share/doc/$direname

make -j$(nproc)
sudo make install DESTDIR=/

sudo mkdir -p /usr/share/doc/$direname
sudo cp -a \
   COPYING README.md TODO \
   /usr/share/doc/$direname
cd ..
sudo rm -rf $direname $filename
echo $VERSION > /var/lib/lfs-custom-packages/$NAME