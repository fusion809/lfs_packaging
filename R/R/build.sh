#!/bin/bash

# Originally a SlackBuild script for R
# Adapted to be used for LFS by Brenton Horne

# Authors as a SlackBuild script: 
# 2019-2025 Andrew Payne <phalange@komputermatrix.com>
# 2014-2017 melikamp, Andrew Rowland

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version, with the following exception:
# the text of the GPL license may be omitted.

# This program is distributed in the hope that it will be useful, but
# without any warranty; without even the implied warranty of
# merchantability or fitness for a particular purpose. Compiling,
# interpreting, executing or merely reading the text of the program
# may result in lapses of consciousness and/or very being, up to and
# including the end of all existence and the Universe as we know it.
# See the GNU General Public License for more details.

# You may have received a copy of the GNU General Public License along
# with this program (most likely, a file named COPYING).  If not, see
# <http://www.gnu.org/licenses/>.

cd $(dirname $0) ; CWD=$(pwd)

PRGNAM=R
VERSION=${VERSION:-4.5.2}
BUILD=${BUILD:-1}
TAG=${TAG:-_SBo}
PKGTYPE=${PKGTYPE:-tgz}

if [ "${R_SHLIB:-yes}" = "yes" ]; then
  r_shlib="--enable-R-shlib"
else
  r_shlib="--disable-R-shlib"
fi
if [ "${BLAS_SHLIB:-yes}" = "yes" ]; then
  blas_shlib="--enable-BLAS-shlib"
else
  blas_shlib="--disable-BLAS-shlib"
fi

if [ -z "$ARCH" ]; then
  case "$( uname -m )" in
    i?86) ARCH=i586 ;;
    arm*) ARCH=arm ;;
       *) ARCH=$( uname -m ) ;;
  esac
fi

# could be useful to other scripts.
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
if ! [[ -f $CWD/$PRGNAM-$VERSION.tar.xz ]]; then
	wget -c https://cran.r-project.org/src/base/$PRGNAM-${VERSION/.*/}/$PRGNAM-$VERSION.tar.xz
fi
tar xvf $CWD/$PRGNAM-$VERSION.tar.xz
cd $PRGNAM-$VERSION
CFLAGS="$SLKCFLAGS" \
CXXFLAGS="$SLKCFLAGS" \
./configure \
  --prefix=/usr \
  --libdir=/usr/lib${LIBDIRSUFFIX} \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --mandir=/usr/man \
  rdocdir=/usr/share/doc/$PRGNAM-$VERSION \
  $r_shlib \
  $blas_shlib

make -j$(nproc)
sudo make install DESTDIR=/

sudo mkdir -p /usr/share/doc/$PRGNAM-$VERSION
sudo cp -a \
   COPYING README SVN-REVISION VERSION VERSION-NICK \
   /usr/share/doc/$PRGNAM-$VERSION
