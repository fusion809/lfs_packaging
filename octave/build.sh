#!/bin/bash
set -e
# Variable declarations
export JAVA_HOME=/opt/jdk
name=octave
homepage="https://www.gnu.org/software/octave/"
description="A high-level language, primarily intended for numerical computations"
version=$(gnu_ver $name)
docs="AUTHORS BUGS CITATION COPYING ChangeLog INSTALL* NEWS README"
depends=(alsa-lib arpack at-spi2-core bash blas-lapack brotli bzip2 cairo coreutils curl cyrus-sasl dbus double-conversion e2fsprogs expat fftw flac fltk fontconfig freeglut freetype fribidi gcc gcc gdk-pixbuf gl2ps glib2 glibc glpk glu glycin gmp gnuplot graphicsmagick graphite2 gtk3 harfbuzz hdf5 hwloc jack java keyutils lame lcms2 libaec libdrm libelf libepoxy libevent libfabric libffi libice libidn2 libogg libpciaccess libpng libpsl libseccomp libSM libsndfile libunistring libvorbis libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxft libxi libxinerama libxkbcommon libxml2 libxmu libxrandr libxrender libxres libxshmfence libxt libxxf86vm llvm lm-sensors lzip make mesa mitkrb mpg123 ncurses nghttp2 numactl openblas openldap openmpi openpmix openssl opus pango pcre2 pixman portaudio qhull qrupdate qscintilla qt6 rapidjson readline sed spirv-tools suitesparse sundials systemd tar texinfo util-linux wayland webkitgtk xz zlib zstd)
direname="$name-$version"
filename="$direname.tar.lz"
export CXXFLAGS="-O2 -fPIC -std=gnu++17"
CFLAGS="-O2 -fPIC"
#source deps-check.sh
# Fetch and unpack source
gnu_download $name $filename
unpk_enter "$filename" "$direname"
# Compile and install
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
oldVer=$(pkgver $name)
if [[ $oldVer != $version ]]; then
	sudo rm -rf /usr/lib/octave/$oldVer /usr/include/octave-$oldVer /usr/share/doc/octave-$oldVer /usr/share/octave/$oldVer
fi
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
echo $version | sudo tee /var/lib/custom-packages/$name
