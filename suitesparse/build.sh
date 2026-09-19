#!/bin/bash
set -e
# Variable declarations
name=suitesparse
_name=SuiteSparse
repo="DrTimothyAldenDavis/SuiteSparse"
version=$(gh_ver $repo)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(bash blas-lapack cmake coreutils gcc gcc glibc gmp make mpfr sed tar wget)
# Fetch and unpack source
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
CMAKE_OPTIONS="-DBLA_VENDOR=Generic \
                 -DCMAKE_INSTALL_PREFIX=/usr \
                 -DCMAKE_BUILD_TYPE=None \
                 -DNSTATIC=ON" \
maki
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
