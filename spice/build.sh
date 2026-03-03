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
# notice, this list of conditions and the following disclaimer.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
set -e
depends=(spice-protocol)
lfs_depends=(bash coreutils make meson sed tar)
blfs_depends=(glib libjpeg-turbo lz4 opus pixman sasl wget)
pip_depends=(pyparsing)
name=spice
version=$(wget -cqO- https://spice-space.org/download/releases/spice-server/ | grep ".tar.bz2\"" | grep -v "alpha\|beta\|rc" | cut -d '"' -f 8 | sed 's/.tar.bz2//g' | tail -n 1 | cut -d '-' -f 2)

DOCS="AUTHORS CHANGELOG.md COPYING README"

# check if libcacard is there
if pkg-config --exists libcacard ; then
  with_cacard="--enable-smartcard"
else
  with_cacard="--disable-smartcard"
fi

direname="$name-$version"
rm -rf $direname
filename="$direname.tar.bz2"
if ! [[ -f $filename ]]; then
	wget -c https://www.spice-space.org/download/releases/spice-server/$filename
fi
tar xvf $filename
cd $direname

CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./configure \
  --prefix=/usr \
  --libdir=/usr/lib \
  --docdir=/usr/share/doc/$direname \
  --disable-static \
  --enable-client \
  --disable-celt051 \
  $with_cacard \

make
sudo make install DESTDIR=/

sudo mkdir -p /usr/share/doc/$direname
sudo cp -a $DOCS /usr/share/doc/$direname

sudo rm -f /usr/lib*/*.la
cd ..
rm -rf $filename $direname
echo $version > /var/lib/lfs-custom-packages/$name