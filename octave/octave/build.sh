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
export JAVA_HOME=/opt/jdk
NAME=octave
VERSION=$(wget -cqO- https://ftp.gnu.org/gnu/octave/ | grep ".tar.gz\"" | tail -n 1 | cut -d '"' -f 8 | sed 's/octave-//g' | sed 's/.tar.gz//g')

DOCS="AUTHORS BUGS CITATION COPYING ChangeLog INSTALL* NEWS README"

export CXXFLAGS="-std=gnu++17"
CFLAGS="-O2 -fPIC"

# Use GraphicsMagick by default.  Fall back on ImageMagick from the full
# Slackware install if it's not present.
#
# GraphicsMagick is default due to the fact that the Octave devs mainly test
# with that, and went several releases before noticing ImageMagick was broken.
# If ImageMagick doesn't work, install GraphicsMagick, or set MAGICK="".
#
# TODO: ImageMagick may no longer be compatible.  The --with-magick argument
# should be the name of a pkg-config file.  Documentation suggests
# "ImageMagick++" which does not exist.  "ImageMagick" and "Magick++" exist;
# the former does not pass configure checks, the latter fails at compile time.
MAGICK=${MAGICK-GraphicsMagick++}
if [ -n "$MAGICK" ] && ! pkg-config --exists $MAGICK; then
  MAGICK=ImageMagick
fi
if [ -n "$MAGICK" ]; then
  MAGICK="--with-magick=$MAGICK"
fi

source deps-check.sh
direname="$NAME-$VERSION"
filename="$direname.tar.lz"
if ! [[ -f $filename ]]; then
	wget -c https://ftpmirror.gnu.org/gnu/$NAME/$filename
fi
rm -rf ${direname}
tar xvf $filename
cd $direname

autoreconf -vif

# Avoid rebuilding the documentation by making stamp-vti newer than its
# dependencies (in particular ./configure, which we may need to patch).
# If you live far enough east or west that the date contained in version.texi
# does not match that file's timestamp when printed accounting for your
# timezone, then the docs get rebuilt with your local date.
find . -name stamp-vti -exec touch {} +

export JAVA_HOME=/opt/jdk
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/qt6/lib:$JAVA_HOME/lib
export PATH=$PATH:/opt/qt6/bin:$JAVA_HOME/bin
export CPPFLAGS="-I/usr/include"
export PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig:$PKG_CONFIG_PATH
./configure \
  --prefix=/usr \
  --libdir=\${exec_prefix}/lib${LIBDIRSUFFIX} \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --mandir=\${prefix}/man \
  --infodir=\${prefix}/info \
  --docdir=\${prefix}/share/doc/$direname \
  --disable-dependency-tracking \
  --with-openssl=auto \
  ${MAGICK} \
  CFLAGS="$CFLAGS" \
  CXXFLAGS="$CFLAGS -std=gnu++17" \
  FFLAGS="$CFLAGS"
make -j$(nproc)
# TODO: May fail if not all optional deps are installed (gl2ps in particular).
#make check
sudo make install-strip DESTDIR=/

sudo mkdir -p /usr/share/doc/$direname
sudo cp -a $DOCS /usr/share/doc/$direname
sudo install -dm755 ../octave_exec /usr/bin/
sudo install -Dm755 ../org.octave.Octave.desktop /usr/share/applications/
sudo sed -i -e "s|/usr/bin/octave|/usr/bin/octave_cli|g" /usr/share/applications/org.octave.Octave.desktop
cd ..
rm -rf $direname ${filename}
