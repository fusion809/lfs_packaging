#!/bin/bash
set -e
# Variable declarations
name=hdf5
homepage="https://www.hdfgroup.org/hdf5"
description="General purpose library and file format for storing scientific data"
repo="HDFGroup/hdf5"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(bash cmake coreutils freetype gcc gcc glib glibc gzip java make sed tar wget zlib)
openmpi)
# Fetch and unpack source
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
export PATH=$PATH:/opt/jdk/bin/
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
common_cmake_args=(
  -DCMAKE_BUILD_TYPE=None
  -DCMAKE_INSTALL_PREFIX=/usr
  -Wno-dev
  -DHDF5_USE_GNU_DIRS=ON
  -DBUILD_STATIC_LIBS=OFF
  -DHDF5_BUILD_CPP_LIB=ON
  -DHDF5_BUILD_HL_LIB=ON
  -DHDF5_BUILD_FORTRAN=ON
  -DHDF5_BUILD_JAVA=ON
  -DHDF5_ENABLE_ZLIB_SUPPORT=ON
  -DHDF5_ENABLE_SZIP_SUPPORT=ON
  -DHDF5_ENABLE_SZIP_ENCODING=ON
  -DHDF5_INSTALL_CMAKE_DIR=lib/cmake/hdf5
)
cmaki "${common_cmake_args[@]}"
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
