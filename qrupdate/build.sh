#!/bin/bash
set -e
depends=(blas lapack)
NAME=qrupdate
VERSION=$(wget -cqO- https://github.com/mpimd-csc/qrupdate-ng/releases | grep "releases/tag/v" | cut -d '"' -f 6 | cut -d '/' -f 6 | sed 's/^v//g')
filename=$NAME-$VERSION.tar.gz
direname="$NAME-ng-$VERSION"
wget -c https://github.com/mpimd-csc/qrupdate-ng/archive/v$VERSION.tar.gz -O $filename
rm -rf $direname
tar xf $filename
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
cmake -B build -S . \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_C_FLAGS="$CFLAGS" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS"
cmake --build build --verbose
sudo cmake --install build
cd ..
sudo rm -rf $filename $direname
echo $VERSION > /var/lib/lfs-custom-packages/$NAME