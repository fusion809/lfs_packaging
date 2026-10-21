#!/bin/bash
set -e
name=ntl
repo=lib$name/$name
homepage="https://www.shoup.net/ntl/"
description="Number theory library."
version=$(gh_ver $repo)
depends=(gcc gf2x glibc gmp sagemath ssw)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://www.shoup.net/$name/$filename"
unpk_enter "$filename" "$direname"
cd src
rm -rf libtool-origin
./configure DEF_PREFIX=/usr SHARED=on NTL_GF2X_LIB=on NATIVE=off TUNE=x86 \
    LIBTOOL=libtool CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}"
make -j$(nproc)
sudo make PREFIX=/usr install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
