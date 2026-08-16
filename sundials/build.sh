#!/bin/bash
set -e
# Variable declarations
name=sundials
version=$(gh_ver "llnl/sundials")
filename=$name-$version.tar.gz
direname="${filename/.tar.gz/}"
depends=(hwloc lapack libfabric numactl openmpi openpmix suitesparse)
lfs_depends=(bash coreutils gcc glibc gzip make python sed systemd tar)
blfs_depends=(cmake gcc libevent wget)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
    wget -c https://github.com/llnl/sundials/archive/refs/tags/v$version.tar.gz -O $filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
cmake_options=(
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DBUILD_STATIC_LIBS=OFF \
    -DENABLE_MPI=ON \
    -DENABLE_PTHREAD=ON	\
    -DENABLE_OPENMP=ON \
    -DENABLE_KLU=ON \
    -DKLU_LIBRARY_DIR=/usr/lib \
    -DKLU_INCLUDE_DIR=/usr/include/suitesparse \
    -DENABLE_LAPACK=ON \
    -DEXAMPLES_INSTALL_PATH=/usr/share/sundials/examples \
    -DCMAKE_C_FLAGS="$CFLAGS" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS"
)
cmaki "$cmake_options[@]"
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name