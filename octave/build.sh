#!/bin/bash

# Originally a Slackware build script for octave
# Now LFS script for octave
# Original author 2012-2024 Kyle Guinn <elyk03@gmail.com>
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
# Variable declarations
export JAVA_HOME=/opt/jdk
name=octave
version=$(wget -cqO- https://ftp.gnu.org/gnu/octave/ | grep ".tar.gz\"" | grep -v "alpha\|beta\|rc" | tail -n 1 | cut -d '"' -f 8 | sed 's/octave-//g' | sed 's/.tar.gz//g')
docs="AUTHORS BUGS CITATION COPYING ChangeLog INSTALL* NEWS README"
depends=(
  arpack
  gl2ps
  glpk
  gnuplot
  graphicsmagick
  hdf5
  lzip
  pcre2
  portaudio
  qhull
  qrupdate
  qscintilla
  rapidjson
  suitesparse
  sundials
)
lfs_depends=(bash coreutils make sed tar texinfo)
blfs_depends=(curl fftw fltk
gcc # Need Fortran support
glu
java
libsndfile
qt6)
direname="$name-$version"
filename="$direname.tar.lz"
export CXXFLAGS="-O2 -fPIC -std=gnu++17"
CFLAGS="-O2 -fPIC"
source deps-check.sh
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://ftpmirror.gnu.org/gnu/$name/$filename
fi
rm -rf ${direname}
tar xvf $filename
# Compile and install
cd $direname
autoreconf -vif
find . -_name stamp-vti -exec touch {} +
export JAVA_HOME=/opt/jdk
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/qt6/lib:$JAVA_HOME/lib
export PATH=$PATH:/opt/qt6/bin:$JAVA_HOME/bin
export CPPFLAGS="-I/usr/include"
export PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig:$PKG_CONFIG_PATH
./configure \
  --prefix=/usr \
  --libdir=\${exec_prefix}/lib \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --mandir=\${prefix}/man \
  --infodir=\${prefix}/info \
  --docdir=\${prefix}/share/doc/$direname \
  --disable-dependency-tracking \
  --with-openssl=auto \
  --with-magick=GraphicsMagick++ \
  CFLAGS="$CFLAGS" \
  CXXFLAGS="$CXXFLAGS" \
  FFLAGS="$CFLAGS"
make -j$(nproc)
sudo make install-strip DESTDIR=/
sudo mkdir -p /usr/share/doc/$direname
sudo cp -a $docs /usr/share/doc/$direname
sudo install -dm755 ../octave_exec /usr/bin/
sudo install -Dm755 ../org.octave.Octave.desktop /usr/share/applications/
sudo sed -i -e "s|/usr/bin/octave|/usr/bin/octave_cli|g" /usr/share/applications/org.octave.Octave.desktop
# Cleanup and add to database
cd ..
sudo rm -rf $direname ${filename}
echo $version > /var/lib/lfs-custom-packages/$name
