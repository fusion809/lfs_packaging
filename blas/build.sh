#!/bin/bash

# Originally a Slackware build script for BLAS
# Now a build script for LFS

# Original author 2014-2024 Kyle Guinn <elyk03@gmail.com>
# Maintainer Brenton Horne
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
depends=()
lfs_depends=(bash coreutils glibc gzip make python sed tar)
blfs_depends=(cmake 
gcc # Fortran support required
wget)
PRGNAM=blas
NAME=lapack
VERSION=$(wget -cqO- https://github.com/Reference-LAPACK/lapack/commits | grep "commit/" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 18)

DOCS="LICENSE"

CFLAGS="-O2 -fPIC"

if ! which gfortran &> /dev/null; then
	echo "GCC hasn't been built with Fortran support. This needs to be addressed!"
	exit
fi
direname="$NAME-$VERSION"
filename="$direname.tar.gz"
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://github.com/Reference-LAPACK/lapack/archive/$VERSION.tar.gz -O $filename
fi
tar xvf $filename
cd $direname
# Avoid adding an RPATH entry to the shared lib.  It's unnecessary (except for
# running the test suite), and it's broken on 64-bit (needs LIBDIRSUFFIX).
mkdir -p shared
cd shared
  cmake \
    -DCMAKE_Fortran_FLAGS:STRING="$CFLAGS" \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=None \
    -DCMAKE_RULE_MESSAGES=OFF \
    -DCMAKE_VERBOSE_MAKEFILE=TRUE \
    -DBUILD_BLAS=ON \
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
      -DCMAKE_Fortran_FLAGS:STRING="$CFLAGS" \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_BUILD_TYPE=None \
      -DCMAKE_RULE_MESSAGES=OFF \
      -DCMAKE_VERBOSE_MAKEFILE=TRUE \
      -DBUILD_BLAS=ON \
      ..
    make -j$(nproc)
    sudo make install/strip DESTDIR=/
  cd ..
fi
sudo mkdir -p /usr/share/doc/$PRGNAM-$VERSION
sudo cp -a $DOCS /usr/share/doc/$PRGNAM-$VERSION
cd ..
sudo rm -rf ${filename} $direname
echo $VERSION > /var/lib/lfs-custom-packages/$NAME