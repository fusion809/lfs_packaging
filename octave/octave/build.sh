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

cd $(dirname $0) ; CWD=$(pwd)
export JAVA_HOME=/opt/OpenJDK-21.0.9-bin
PRGNAM=octave
VERSION=${VERSION:-11.1.0}
BUILD=${BUILD:-1}
TAG=${TAG:-_SBo}
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
DOCS="AUTHORS BUGS CITATION COPYING ChangeLog INSTALL* NEWS README"

export CXXFLAGS="-std=gnu++17"

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

set -e

if ! which lzip &> /dev/null; then
	echo "lzip is not installed and is used to decompress the source code."
	exit
fi

if ! [[ -f /usr/lib/liblapack.so ]]; then
	echo "LAPACK is not installed. You need it to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libarpack.so ]]; then
	echo "ARPACK is not installed. You need it to compile GNU Octave."
	exit
fi

if ! [[ -f /opt/qt6/lib/libQt6Core.so ]]; then
	echo "Qt6 is not installed. You need it to compile GNU Octave with a GUI."
	exit
fi

if ! [[ -f /opt/qt6/lib/libqscintilla2_qt6.so ]]; then
	echo "QScintilla with Qt6 support is not installed. You need it to compile GNU Octave with a GUI."
fi

if ! [[ -f /usr/lib/libhdf5.so ]]; then
	echo "HDF5 is not installed. It is required to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libfftw3.so ]]; then
	echo "FFTW is not installed. It is required to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libGraphicsMagick.so ]]; then
	echo "GraphicsMagick is not installed. It is required to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libglpk.so ]]; then
	echo "GLPK is not installed and is required to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libcurl.so ]]; then
	echo "cURL is not installed. It is required to install GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libqhull.so ]]; then
	echo "QHull is not installed and it is required to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libGLU.so ]]; then
	echo "GLU is not installed and it is required to compile GNU Octave."
	exit
fi

if ! [[ -d /usr/share/ghostscript ]]; then
	echo "Ghostscript isn't installed and it is required to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libsundials_core.so ]]; then
	echo "Sundials isn't installed and it is required to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libgl2ps.so ]]; then
	echo "gl2ps isn't installed and it is required to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libsndfile.so ]]; then
	echo "libsndfile isn't installed and is required to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/lib/libqrupdate.so ]]; then
	echo "Qrupdate isn't installed and is required to compile GNU Octave."
	exit
fi

if ! [[ -f /usr/bin/pcre2-config ]]; then
	echo "pcre2 isn't installed and is required to compile GNU Octave."
	exit
fi

if ! which gfortran &> /dev/null; then
	echo "gfortran is not found within PATH. It is required to compile GNU Octave and its dependencies like LAPACK."
	exit
fi

if ! [[ -f /usr/lib/libsuitesparse_mongoose.so ]]; then
	echo "suitesparse isn't installed and is required to comple GNU Octave."
	exit
fi

if ! which info &> /dev/null; then
	echo "texinfo isn't installed and is required to compile GNU Octave."
	exit
fi

if ! which gnuplot &> /dev/null ; then
	echo "Gnuplot isn't installed and it is required for some plotting in Octave."
fi

if ! which fltk &> /dev/null; then
	echo "FLTK is required by some features for GNU Octave."
fi

if ! [[ -f /usr/lib/libportaudio.so ]]; then
	echo "PortAudio isn't installed and is required for audio support in GNU Octave."
fi

if ! [[ -f /usr/include/rapidjson/prettywriter.h ]]; then
	echo "RapidJSON isn't installed and is required for JSON support in Octave."
fi

if ! [[ -d /opt/OpenJDK-21.0.9-bin/bin ]]; then
	echo "Java not found. It is required to build GNU Octave."
	exit
fi
if ! [[ -f $PRGNAM-$VERSION.tar.lz ]]; then
	wget -c https://ftpmirror.gnu.org/gnu/$PRGNAM/$PRGNAM-$VERSION.tar.lz
fi
rm -rf $PRGNAM-$VERSION
tar xvf $CWD/$PRGNAM-$VERSION.tar.lz
cd $PRGNAM-$VERSION

autoreconf -vif

# Avoid rebuilding the documentation by making stamp-vti newer than its
# dependencies (in particular ./configure, which we may need to patch).
# If you live far enough east or west that the date contained in version.texi
# does not match that file's timestamp when printed accounting for your
# timezone, then the docs get rebuilt with your local date.
find . -name stamp-vti -exec touch {} +

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/qt6/lib
export PATH=$PATH:/opt/qt6/bin
export JAVA_HOME=/opt/OpenJDK-21.0.9-bin
export CPPFLAGS="-I/usr/include"
export PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig:$PKG_CONFIG_PATH
./configure \
  --prefix=/usr \
  --libdir=\${exec_prefix}/lib${LIBDIRSUFFIX} \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --mandir=\${prefix}/man \
  --infodir=\${prefix}/info \
  --docdir=\${prefix}/share/doc/$PRGNAM-$VERSION \
  --disable-dependency-tracking \
  --with-openssl=auto \
  ${MAGICK} \
  CFLAGS="$SLKCFLAGS" \
  CXXFLAGS="$SLKCFLAGS -std=gnu++17" \
  FFLAGS="$SLKCFLAGS"
  make -j$(nproc)
# TODO: May fail if not all optional deps are installed (gl2ps in particular).
#make check
sudo make install-strip DESTDIR=/

sudo mkdir -p /usr/share/doc/$PRGNAM-$VERSION
sudo cp -a $DOCS /usr/share/doc/$PRGNAM-$VERSION
sudo install -dm755 $CWD/octave_exec /usr/bin/
sudo sed -i -e "s|/usr/bin/octave|/usr/bin/octave_cli|g" /usr/share/applications/org.octave.Octave.desktop
