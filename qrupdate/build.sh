#!/bin/bash
set -e
# Variable declarations
name=qrupdate
version=$(gh_ver "mpimd-csc/qrupdate-ng" "qrupdate")
filename=$name-$version.tar.gz
direname="$name-ng-$version"
depends=(blas lapack)
lfs_depends=(bash coreutils gcc glibc gzip make sed tar)
blfs_depends=(cmake
gcc # Fortran support needed
wget)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/mpimd-csc/qrupdate-ng/archive/v$version.tar.gz -O $filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
cmake_options=(
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_C_FLAGS="$CFLAGS" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS"
)
cmaki "${cmake_options[@]}"
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
