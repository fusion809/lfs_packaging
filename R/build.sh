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
# Variable declarations
name=R
function get_version {
  local up_ver1=$(wget -cqO- https://cran.r-project.org/sources.html | grep ".tar.gz" | grep -v "alpha\|beta\|\.rc" | head -n 1 | cut -d '"' -f 2 | cut -d '/' -f 4 | sed 's/.tar.gz//g' | cut -d '-' -f 2) 
  if echo "$up_ver1" | grep -q "[0-9]\.[0-9]"; then
		echo "$up_ver1"
		return 0
	fi

  local up_ver2=$(
    curl -fsSL https://cran.r-project.org/src/base/ |
    grep -oE 'href="R-[0-9]+/"' |
    grep -oE '[0-9]+' |
    sort -V |
    tail -n1 |
    xargs -I{} curl -fsSL "https://cran.r-project.org/src/base/R-{}/" |
    grep -oE 'R-[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz' |
    sort -V |
    tail -n1 |
    sed 's/^R-//; s/\.tar\.gz$//'
  )
  if echo "$up_ver2" | grep -q "[0-9]\.[0-9]"; then
    echo "$up_ver2"
    return 0
  fi

  local arch_ver=$(aver $name)
  if echo "$arch_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$arch_ver"
		return 0
	fi
}
version=$(get_version)
direname="$name-$version"
filename="$direname.tar.xz"
depends=(blas lapack pcre2)
lfs_depends=(bash bzip2 coreutils glibc make readline sed tar xz zlib zstd)
blfs_depends=(cairo curl gcc glib icu java libjpeg-turbo libpng libtiff libtirpc libx11 libxmu libxt pango tk which zip)
# Fetch and unpack source
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://cran.r-project.org/src/base/$name-${version/.*/}/$filename
fi
tar xvf $filename
# Compile and install
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
  --enable-R-shlib \
  --with-blas="-lblas" \
  --with-lapack="-llapack"

make -j$(nproc)
sudo make install DESTDIR=/

sudo mkdir -p /usr/share/doc/$direname
sudo cp -a \
   COPYING README SVN-REVISION VERSION VERSION-NICK \
   /usr/share/doc/$direname
cd ..
sudo install -Dm755 $name.desktop /usr/share/applications
# Cleanup and add to database
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
