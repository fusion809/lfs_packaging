#!/bin/bash
set -e
# Variable declarations
export JAVA_HOME=/opt/jdk
name=octave
version=$(gnu_ver $name)
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
find . -name stamp-vti -exec touch {} +
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
sudo install -Dm755 $HOME/lfs_packaging/octave/octave_exec /usr/bin/
sudo install -Dm755 $HOME/lfs_packaging/octave/org.octave.Octave.desktop /usr/share/applications/
sudo sed -i -e "s|/usr/bin/octave$|/usr/bin/octave_exec|g" \
       -e "s|/usr/bin/octave |/usr/bin/octave_exec |g" 	/usr/share/applications/org.octave.Octave.desktop
# Cleanup and add to database
cd ..
sudo rm -rf $direname ${filename}
echo $version > /var/lib/custom-packages/$name
