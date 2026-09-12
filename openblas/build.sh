#!/bin/bash
set -e
name=openblas
repo=OpenMathLib/OpenBLAS
version=$(gh_ver $repo)
filename="OpenBLAS-$version.tar.gz"
direname="${filename/.tar.*/}"
# gcc needs Fortran
depends=(cmake gcc glibc gzip tar)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/releases/download/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
#options=(-DCMAKE_INSTALL_PREFIX=/usr \
#    -DBUILD_SHARED_LIBS=ON \
#    -DBUILD_TESTING=OFF \
#    -DNO_AFFINITY=ON \
#    -DUSE_OPENMP=1 \
#    -DNO_WARMUP=1 \
#    -DTARGET=CORE2 \
#    -DNUM_THREADS=64 \
#    -DDYNAMIC_ARCH=ON \
#    -DINTERFACE64=1)
options=(-DCMAKE_INSTALL_PREFIX=/usr \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=OFF \
    -DNO_AFFINITY=ON \
    -DUSE_OPENMP=1 \
    -DNO_WARMUP=1 \
    -DTARGET=CORE2 \
    -DNUM_THREADS=64 \
    -DDYNAMIC_ARCH=ON)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
