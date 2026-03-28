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
blfs_depends=(cmake gcc wget)
_name=blas
name=blas
version=$(wget -cqO- https://github.com/Reference-LAPACK/lapack/commits | grep "commit/" | grep -v "alpha\|beta\|\.rc" | head -n 1 | cut -d '"' -f 18)

DOCS="LICENSE"

CFLAGS="-O2 -fPIC"

if ! which gfortran &> /dev/null; then
        echo "GCC hasn't been built with Fortran support. This needs to be addressed!"
        exit
fi
direname="lapack-$version"
filename="$direname.tar.gz"
rm -rf $direname
if ! [[ -f $filename ]]; then
        wget -c https://github.com/Reference-LAPACK/lapack/archive/$version.tar.gz -O $filename
fi
tar xvf $filename
cd $direname

export DDIR=/tmp/custom_${name}dir
rm -rf $DDIR
mkdir -p $DDIR

# Avoid adding an RPATH entry to the shared lib.
mkdir -p shared
cd shared
  cmake \
    -DCMAKE_Fortran_FLAGS:STRING="$CFLAGS" \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=None \
    -DCMAKE_RULE_MESSAGES=OFF \
    -DCMAKE_VERBOSE_MAKEFILE=TRUE \
    -DCBLAS=ON \
    -DLAPACKE=OFF \
    -DBUILD_DEPRECATED=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_SKIP_RPATH=YES \
    ..
  make -j$(nproc)
  make install/strip DESTDIR="$DDIR" || true
cd ..

# cmake doesn't appear to let us build both shared and static libs
# at the same time, so build it twice.
if [ "${STATIC:-no}" != "no" ]; then
  mkdir -p static
  cd static
    cmake \
      -DCMAKE_Fortran_FLAGS:STRING="$CFLAGS" \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_BUILD_TYPE=None \
      -DCMAKE_RULE_MESSAGES=OFF \
      -DCMAKE_VERBOSE_MAKEFILE=TRUE \
      -DCBLAS=ON \
      -DLAPACKE=OFF \
      -DBUILD_DEPRECATED=OFF \
      ..
    make -j$(nproc)
    make install/strip DESTDIR="$DDIR" || true
  cd ..
fi

# Clean LAPACK out of the BLAS package
rm -f $DDIR/usr/lib/liblapack.* $DDIR/usr/lib/pkgconfig/lapack*.pc
rm -f $DDIR/usr/lib/cmake/*/lapack-*.cmake $DDIR/usr/lib/cmake/*/lapacke-*.cmake
rm -f $DDIR/usr/include/lapack*.h

sudo cp -va $DDIR/* /

sudo rm -rf /usr/share/doc/$_name-*
sudo mkdir -p /usr/share/doc/$_name-$version
sudo cp -a $DOCS /usr/share/doc/$_name-$version
cd ..
sudo rm -rf ${filename} $direname
echo $version > /var/lib/custom-packages/$name
if [ -d "$DDIR" ] && [ "$(ls -A "$DDIR" 2>/dev/null)" ]; then
   find "$DDIR" -type f -o -type l | sed "s|^$DDIR||" | sudo tee -a "/var/lib/custom-packages/$name" > /dev/null
fi
sudo chmod 777 /var/lib/custom-packages/$name
sudo rm -rf $DDIR
