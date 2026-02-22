#!/bin/sh
#
# Slackware build script for Gnuplot
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

NAME=gnuplot
VERSION=$(wget -cqO- https://sourceforge.net/p/gnuplot/gnuplot-main/ref/master/tags/ | grep "/tree" | grep -v "git-conv" | tail -n 1 | cut -d '/' -f 6)
BUILD=1

CWD=${CWD:-`pwd`}

SRC=$CWD/$NAME-$VERSION
rm -rf $SRC

wget -c https://sourceforge.net/projects/gnuplot/files/gnuplot/$VERSION/$NAME-$VERSION.tar.gz
# Extract the sources
tar -zxvf $CWD/$NAME-$VERSION.tar.gz || exit 3
cd $SRC

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

rm -rf $SRC
