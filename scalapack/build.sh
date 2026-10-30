#!/bin/bash
set -e
name=scalapack
repo=Reference-ScaLAPACK/$name
homepage="http://www.netlib.org/scalapack"
description="Subset of scalable LAPCK routines."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-D CMAKE_INSTALL_PREFIX:PATH=/usr \
        -D BUILD_SHARED_LIBS:BOOL=ON \
        -D SCALAPACK_BUILD_TESTS:BOOL=OFF \
        -D CMAKE_BUILD_TYPE:STRING=Release \
        -D CMAKE_Fortran_FLAGS:STRING="$FCFLAGS -fallow-argument-mismatch" \
        -D CMAKE_C_FLAGS:STRING="$CFLAGS -Wno-implicit-function-declaration" \
	-D CMAKE_C_STANDARD:STRING="17")
sed -i 's/cmake_minimum_required(VERSION 2.8)/cmake_minimum_required(VERSION 3.6)/g' BLACS/INSTALL/CMakeLists.txt
cmaki "${cmake_options[@]}"
cd ..
sudo cp -r PBLAS/SRC/*.h /usr/include
sudo cp -r BLACS/SRC/*.h /usr/include
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
