#!/bin/bash
set -e
name=abseil-cpp
version=$(gh_ver abseil/abseil-cpp)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(cmake gcc glibc)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/abseil/abseil-cpp/releases/download/$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr   \
      -D CMAKE_BUILD_TYPE=Release    \
      -D CMAKE_SKIP_INSTALL_RPATH=ON \
      -D ABSL_PROPAGATE_CXX_STD=ON   \
      -D BUILD_SHARED_LIBS=ON        \
      -G Ninja)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
