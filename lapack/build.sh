#!/bin/bash
set -e
# Variable declarations
name=lapack
version=$(git ls-remote https://github.com/Reference-LAPACK/lapack.git HEAD | awk '{print $1}')
depends=(blas glib2 libX11 libXext libXxf86vm libpciaccess libxshmfence mesa mitkrb pcre2 wayland)
lfs_depends=(bash bzip2 coreutils dbus e2fsprogs expat gcc glibc gzip libelf libffi make openssl python sed systemd tar xz zlib zstd)
blfs_depends=(brotli cmake double-conversion flac fontconfig freetype gcc graphite2 harfbuzz karchive keyutils lame libXau libXdmcp libdrm libogg libpng libsndfile libvorbis libxcb libxkbcommon libxml2 libxslt llvm lm-sensors mpg123 opus pulseaudio qt6 spirv-tools wget)
docs="LICENSE README.md DOCS/lapack.png DOCS/lawn81.tex DOCS/org2.ps"
direname="lapack-$version"
filename="$direname.tar.gz"
CFLAGS="-O2 -fPIC"

# Check deps
if ! [[ -f /usr/lib/libblas.so ]]; then
        echo "libblas.so not found in /usr/lib. You need BLAS installed first!"
        exit
fi

# Fetch and unpack source
if ! [[ -f $filename ]]; then
        wget -c https://github.com/Reference-LAPACK/lapack/archive/$version.tar.gz -O $filename
fi
rm -rf $direname
tar xvf $filename
# Compile and install
cd $direname

if pkg-config --exists xblas; then
  use_xblas='-DUSE_XBLAS=ON'
fi

# Avoid adding an RPATH entry to the shared lib.
mkdir -p shared
cd shared
  cmake \
    -DCMAKE_Fortran_FLAGS:STRING="$CFLAGS" \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=None \
    -DCMAKE_RULE_MESSAGES=OFF \
    -DCMAKE_VERBOSE_MAKEFILE=TRUE \
    -DUSE_OPTIMIZED_BLAS=ON \
    -DCBLAS=ON \
    -DLAPACKE=ON \
    -DBUILD_DEPRECATED=OFF \
    $use_xblas \
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
      -DUSE_OPTIMIZED_BLAS=ON \
      -DCBLAS=ON \
      -DLAPACKE=ON \
      -DBUILD_DEPRECATED=OFF \
      $use_xblas \
      ..
    make -j$(nproc)
    make install/strip DESTDIR="$DDIR" || true
  cd ..
fi

# Clean BLAS out of LAPACK package layout
rm -f $DDIR/usr/lib/libblas.* $DDIR/usr/lib/pkgconfig/blas*.pc
rm -f $DDIR/usr/lib/libcblas.* $DDIR/usr/lib/pkgconfig/cblas*.pc
rm -f $DDIR/usr/lib/cmake/*/blas-*.cmake $DDIR/usr/lib/cmake/*/cblas-*.cmake
rm -f $DDIR/usr/include/cblas*.h

sudo cp -va $DDIR/* /

sudo rm -rf /usr/share/doc/$name-*
sudo mkdir -p /usr/share/doc/$direname
sudo cp -a $docs /usr/share/doc/$direname
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
if [ -d "$DDIR" ] && [ "$(ls -A "$DDIR" 2>/dev/null)" ]; then
   find "$DDIR" -type f -o -type l | sed "s|^$DDIR||" | sudo tee -a "/var/lib/custom-packages/$name" > /dev/null
fi
sudo chmod 777 /var/lib/custom-packages/$name
sudo rm -rf $DDIR
