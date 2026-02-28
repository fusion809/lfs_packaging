#!/bin/sh
# Adapted by Brenton Horne for LFS
# Originally a Slackware build script for Gnuplot
# Copyright (C) 2008-2020 Georgi D. Sotirov <gdsotirov@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# Visit SlackPack at https://sotirov-bg.net/slackpack/
#
set -e
depends=()
NAME=gnuplot
VERSION=$(wget -cqO- https://sourceforge.net/p/gnuplot/gnuplot-main/ref/master/tags/ | grep "/tree" | grep -v "git-conv" | tail -n 1 | cut -d '/' -f 6)

SRC=$NAME-$VERSION
rm -rf $SRC

filename="$SRC.tar.gz"
wget -c https://sourceforge.net/projects/gnuplot/files/gnuplot/$VERSION/$filename
# Extract the sources
tar -zxvf $filename || exit 3
cd $SRC

CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"

./configure --prefix=/usr \
            --sysconfdir=/etc \
            --mandir=/usr/man \
            --infodir=/usr/info \
            --datadir=/usr/share/gnuplot \
            --with-caca \
            --with-readline=gnu 

make -j$(nproc) pkglibexecdir=/usr/bin || exit 1
sudo make DESTDIR=/ install || exit 2

DOCDIR="/usr/share/doc/$NAME-$VERSION"
sudo mkdir -p $DOCDIR
sudo cp Copyright RELEASE_NOTES NEWS $DOCDIR 
cd ..
sudo rm -rf $SRC $filename
echo $VERSION > /var/lib/lfs-custom-packages/$NAME
