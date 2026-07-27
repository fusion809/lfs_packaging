#!/bin/bash
set -e
# Variable declarations
name=suitesparse
_name=SuiteSparse
source ~/lfs_packaging/shared-funcs.sh
version=$(wget -cqO- https://github.com/DrTimothyAldenDavis/SuiteSparse/releases | grep "releases/tag/v" | grep -v "paru\|alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6 | sed 's/^v//g')
#version=$(github_ver DrTimothyAldenDavis/SuiteSparse | sed 's/v//g')
filename="$_name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(blas lapack)
lfs_depends=(btomsh coreutils glibc gmp make mpfr sed tar)
blfs_depends=(cmake
gcc # Fortran support needed
wget)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
    wget -c https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/v$version.tar.gz -O $filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
CMAKE_OPTIONS="-DBLA_VENDOR=Generic \
                 -DCMAKE_INSTALL_PREFIX=/usr \
                 -DCMAKE_BUILD_TYPE=None \
                 -DNSTATIC=ON" \
make -j$(nproc)
sudo make install
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
