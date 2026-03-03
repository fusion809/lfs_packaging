#!/bin/bash
set -e
depends=(blas lapack)
lfs_depends=(bash coreutils glibc gzip make sed tar)
blfs_depends=(cmake
gcc # Fortran support needed
wget)
name=qrupdate
version=$(wget -cqO- https://github.com/mpimd-csc/qrupdate-ng/releases | grep "releases/tag/v" | grep -v "alpha\|beta\|rc" | cut -d '"' -f 6 | cut -d '/' -f 6 | sed 's/^v//g')
filename=$name-$version.tar.gz
direname="$name-ng-$version"
wget -c https://github.com/mpimd-csc/qrupdate-ng/archive/v$version.tar.gz -O $filename
rm -rf $direname
tar xf $filename
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
cmake -B build -S . \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_POLICY_version_MINIMUM=3.5 \
    -DCMAKE_C_FLAGS="$CFLAGS" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS"
cmake --build build --verbose
sudo cmake --install build
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/lfs-custom-packages/$name