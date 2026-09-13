#!/bin/bash
set -e
# Combine lapack and blas
depends=()
depends=(bash coreutils gcc glibc gzip make python sed tar cmake gcc wget)
name=blas-lapack
repo="Reference-LAPACK/lapack"
version=$(gh_com $repo)
CFLAGS="-O2 -fPIC"

if ! which gfortran &> /dev/null; then
        echo "GCC hasn't been built with Fortran support. This needs to be addressed!"
        exit
fi
direname="lapack-$version"
filename="$direname.tar.gz"
rm -rf $direname
if ! [[ -f $filename ]]; then
        wget -c --progress=bar:force https://github.com/$repo/archive/$version.tar.gz -O $filename
fi
tar xf $filename
cd $direname

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
  sudo make install/strip
cd ..

# cmake doesn't appear to let us build both shared and static libs
# at the same time, so build it twice.
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
  sudo make install/strip
cd ../..

sudo rm -rf ${filename} $direname
echo $version | sudo tee /var/lib/custom-packages/$name
