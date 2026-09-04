#!/bin/bash
set -e
name=fmt
repo=fmtlib/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(cmake gcc glibc)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/fmtlib/fmt/archive/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr     \
      -D CMAKE_INSTALL_LIBDIR=/usr/lib \
      -D BUILD_SHARED_LIBS=ON          \
      -D FMT_TEST=OFF                  \
      -G Ninja)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
