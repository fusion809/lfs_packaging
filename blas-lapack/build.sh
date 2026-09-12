#!/bin/bash
set -e
# Combine lapack and blas
depends=()
lfs_depends=(bash coreutils gcc glibc gzip make python sed tar)
blfs_depends=(cmake gcc wget)
name=blas-lapack
repo="Reference-LAPACK/lapack"
version=$(gh_com $repo)

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
        wget -c https://github.com/$repo/archive/$version.tar.gz -O $filename
fi
tar xvf $filename
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
    sudo make install/strip
  cd ..
fi

sudo rm -rf /usr/share/doc/blas-*
sudo rm -rf /usr/share/doc/$name-*
sudo mkdir -p /usr/share/doc/$name-$version
sudo cp -a $DOCS /usr/share/doc/$name-$version
cd ..
sudo rm -rf ${filename} $direname
echo $version | sudo tee /var/lib/custom-packages/$name
