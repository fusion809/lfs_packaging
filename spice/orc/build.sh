#!/bin/bash

# Originally a Slackware build script for spice
# Repurposed as a LFS build script by Brenton Horne
# Originally authored by 2013-2025 Matteo Bernardini <ponce@slackbuilds.org>, Pisa, Italy
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
NAME=orc
VERSION=$(wget -cqO- https://gstreamer.freedesktop.org/src/orc/ | grep ".tar.xz\"" | cut -d '"' -f 2 | sed 's/.tar.xz//g' | cut -d '-' -f 2 | tail -n 1)
BUILD=${BUILD:-1}
TAG=${TAG:-_SBo}

DOCS="CONTRIBUTING.md COPYING README RELEASE ROADMAP.md"

# check if libcacard is there
if pkg-config --exists libcacard ; then
  with_cacard="--enable-smartcard"
else
  with_cacard="--disable-smartcard"
fi

set -e 

direname="$NAME-$VERSION"
filename="$direname.tar.xz"
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c http://gstreamer.freedesktop.org/src/$NAME/$filename
fi
tar xvf $filename
cd $direname

mkdir build &&
cd    build &&
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
meson setup --prefix=/usr --buildtype=release .. &&
ninja
sudo ninja install

cd ..
sudo mkdir -p /usr/share/doc/$direname
for i in $DOCS
do
	sudo cp -a $i /usr/share/doc/$direname
done

sudo rm -f /usr/lib*/*.la
cd ..
rm -rf $direname $filename
