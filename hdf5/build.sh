#!/bin/bash
set -e
# Variable declarations
name=hdf5
version=$(gh_ver "HDFGroup/hdf5")
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(libaec
openmpi)
lfs_depends=(bash coreutils gcc glib glibc gzip make sed tar zlib)
blfs_depends=(cmake freetype gcc java wget)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/HDFGroup/hdf5/releases/download/$version/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
export PATH=$PATH:/opt/jdk/bin/
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
cd $direname
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
cmake -S . -B build "${common_cmake_args[@]}"
cd build
make -j$(nproc)
sudo make install
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
