#!/bin/bash
set -e
# Variable declarations
name=qrupdate
homepage="https://sourceforge.net/projects/qrupdate"
description="Fortran library for fast updates of QR and Cholesky decompositions"
repo=mpimd-csc/qrupdate-ng
version=$(gh_ver $repo $name)
filename=$name-$version.tar.gz
direname="$name-ng-$version"
depends=(bash blas-lapack cmake coreutils gcc glibc gzip make sed tar wget)
# Fetch and unpack source
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
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
echo $version | sudo tee /var/lib/custom-packages/$name
