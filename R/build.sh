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
# with this program (most likely, a file _named COPYING).  If not, see
# <http://www.gnu.org/licenses/>.

set -e
depends=(blas lapack pcre2) # Provided by lfs_packaging
lfs_depends=(bash bzip2 coreutils glibc make readline sed tar xz zlib zstd) # Provided by LFS
blfs_depends=(cairo curl 
gcc # You need GCC built with Fortran support; LFS build doesn't support Fortran
glib icu java libjpeg-turbo libpng libtiff libtirpc
libx11 libxmu libxt # Part of Xorg libraries
pango tk which zip) # Provided by BLFS
name=R
version=$(wget -cqO- https://cran.r-project.org/sources.html | grep ".tar.gz" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 2 | cut -d '/' -f 4 | sed 's/.tar.gz//g' | cut -d '-' -f 2)

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

direname="$name-$version"
filename="$direname.tar.xz"
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://cran.r-project.org/src/base/$name-${version/.*/}/$filename
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
  rdocdir=/usr/share/doc/$direname \
  $r_shlib \
  $blas_shlib

make -j$(nproc)
sudo make install DESTDIR=/

sudo mkdir -p /usr/share/doc/$direname
sudo cp -a \
   COPYING README SVN-REVISION version version-NICK \
   /usr/share/doc/$direname
cd ..
sudo install -Dm755 $name.desktop /usr/share/applications
sudo rm -rf $filename $direname
echo $version > /var/lib/lfs-custom-packages/$name
