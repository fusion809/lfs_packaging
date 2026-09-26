#!/bin/bash
set -e
# Variable declarations
name=sundials
homepage="https://computing.llnl.gov/projects/sundials"
description="Suite of nonlinear differential/algebraic equation solvers"
repo="llnl/sundials"
version=$(gh_ver $repo)
filename=$name-$version.tar.gz
direname="${filename/.tar.gz/}"
depends=(bash cmake coreutils gcc gcc glibc gzip hwloc lapack libevent libfabric make numactl openmpi openpmix python sed suitesparse systemd tar wget)
# Fetch and unpack source
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
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
cmaki "${cmake_options[@]}"
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
