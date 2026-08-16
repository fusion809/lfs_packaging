#!/bin/bash
set -e
depends=()
lfs_depends=(bash coreutils gcc glibc gzip make python sed tar)
blfs_depends=(cmake gcc wget)
_name=blas
name=blas
version=$(git ls-remote https://github.com/Reference-LAPACK/lapack.git HEAD | awk '{print $1}')

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