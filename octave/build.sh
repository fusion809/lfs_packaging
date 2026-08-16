#!/bin/bash
set -e
# Variable declarations
export JAVA_HOME=/opt/jdk
name=octave
version=$(gnu_ver $name)
docs="AUTHORS BUGS CITATION COPYING ChangeLog INSTALL* NEWS README"
depends=(arpack blas gl2ps glib2 glpk gnuplot graphicsmagick gtk3 hdf5 hwloc jack lapack libICE libSM libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXft libXi libXinerama libXmu libXrandr libXrender libXres libXt libXxf86vm libaec libfabric libpciaccess libxshmfence lzip mesa mitkrb numactl openldap openmpi openpmix pango pcre2 portaudio qhull qrupdate qscintilla rapidjson suitesparse sundials wayland)
lfs_depends=(bash bzip2 coreutils dbus e2fsprogs expat gcc glibc gmp libelf libffi make ncurses openssl readline sed systemd tar texinfo util-linux xz zlib zstd)
blfs_depends=(alsa-lib at-spi2-core brotli cairo curl cyrus-sasl double-conversion fftw flac fltk fontconfig freeglut freetype fribidi gcc gdk-pixbuf glu glycin graphite2 harfbuzz java keyutils lame lcms2 libXau libXdmcp libdrm libepoxy libevent libidn2 libogg libpng libpsl libseccomp libsndfile libunistring libvorbis libxcb libxkbcommon libxml2 llvm lm-sensors mpg123 nghttp2 opus pixman qt6 spirv-tools webkitgtk)
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
