#!/bin/bash
set -e
# Variable declarations
name=suitesparse
_name=SuiteSparse
version=$(gh_ver "DrTimothyAldenDavis/SuiteSparse")
filename="$_name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(blas-lapack bash coreutils gcc glibc gmp make mpfr sed tar cmake gcc wget)
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
maki
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version sudo tee /var/lib/custom-packages/$name
