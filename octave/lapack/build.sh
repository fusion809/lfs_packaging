#!/bin/bash

# Originally a Slackware build script for LAPACK
# Now a build script for LFS

# Original author 2014-2024 Kyle Guinn <elyk03@gmail.com>
# Current maintainer Brenton Horne
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

PRGNAM=lapack
SRCNAM=lapack
VERSION=${VERSION:-c0c64400dae807bd7e3752456f57e346667dd963}
BUILD=${BUILD:-1}
PKGTYPE=${PKGTYPE:-tgz}

if [ -z "$ARCH" ]; then
  case "$(uname -m)" in
    i?86) ARCH=i586 ;;
    arm*) ARCH=arm ;;
       *) ARCH=$(uname -m) ;;
  esac
fi

if [ ! -z "${PRINT_PACKAGE_NAME}" ]; then
  echo "$PRGNAM-$VERSION-$ARCH-$BUILD$TAG.$PKGTYPE"
  exit 0
fi

DOCS="LICENSE README.md DOCS/lapack.png DOCS/lawn81.tex DOCS/org2.ps"

if [ "$ARCH" = "i586" ]; then
  SLKCFLAGS="-O2 -march=i586 -mtune=i686"
elif [ "$ARCH" = "i686" ]; then
  SLKCFLAGS="-O2 -march=i686 -mtune=i686"
elif [ "$ARCH" = "x86_64" ]; then
  SLKCFLAGS="-O2 -fPIC"
else
  SLKCFLAGS="-O2"
fi

set -e

if ! [[ -f /usr/lib/libblas.so ]]; then
	echo "libblas.so not found in /usr/lib. You need BLAS installed first!"
	exit
fi
	
wget -c https://github.com/Reference-LAPACK/lapack/archive/$VERSION.tar.gz
rm -rf $SRCNAM-$VERSION
tar xvf $CWD/$VERSION.tar.gz
cd $SRCNAM-${VERSION}

# Allow building only the LAPACK component.
patch -p1 < $CWD/cmake-piecewise.diff || echo "Patching failed"

if pkg-config --exists xblas; then
  use_xblas='-DUSE_XBLAS=ON'
fi

# Avoid adding an RPATH entry to the shared lib.  It's unnecessary (except for
# running the test suite), and it's broken on 64-bit (needs LIBDIRSUFFIX).
mkdir -p shared
cd shared
  cmake \
    -DCMAKE_Fortran_FLAGS:STRING="$SLKCFLAGS" \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=None \
    -DCMAKE_RULE_MESSAGES=OFF \
    -DCMAKE_VERBOSE_MAKEFILE=TRUE \
    -DUSE_OPTIMIZED_BLAS=ON \
    -DBUILD_LAPACK=ON \
    -DBUILD_DEPRECATED=ON \
    $use_xblas \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_SKIP_RPATH=YES \
    ..
  make -j$(nproc)
  sudo make install/strip DESTDIR=/
cd ..

# cmake doesn't appear to let us build both shared and static libs
# at the same time, so build it twice.  This may build a non-PIC library
# on some architectures, which should be faster.
if [ "${STATIC:-no}" != "no" ]; then
  mkdir -p static
  cd static
    cmake \
      -DCMAKE_Fortran_FLAGS:STRING="$SLKCFLAGS" \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_BUILD_TYPE=None \
      -DCMAKE_RULE_MESSAGES=OFF \
      -DCMAKE_VERBOSE_MAKEFILE=TRUE \
      -DUSE_OPTIMIZED_BLAS=ON \
      -DBUILD_LAPACK=ON \
      -DBUILD_DEPRECATED=ON \
      $use_xblas \
      ..
    make -j$(nproc)
    sudo make install/strip DESTDIR=/
  cd ..
fi

sudo mkdir -p /usr/share/doc/$PRGNAM-$VERSION
sudo cp -a $DOCS /usr/share/doc/$PRGNAM-$VERSION
