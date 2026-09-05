#!/bin/bash
set -e
name=graphite2
repo=silnrsi/graphite
version=$(gh_ver $repo)
filename="$name-$version.tgz"
direname="${filename/.tgz/}"
depends=(cmake)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/silnrsi/graphite/releases/download/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -i '/cmake_policy(SET CMP0012 NEW)/d' CMakeLists.txt &&
sed -i 's/PythonInterp/Python3/' CMakeLists.txt          &&
find . -name CMakeLists.txt | xargs sed -i 's/VERSION 2.8.0 FATAL_ERROR/VERSION 4.0.0/'
sed -i '/Font.h/i #include <cstdint>' tests/featuremap/featuremaptest.cpp
cmaki -D CMAKE_INSTALL_PREFIX=/usr
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
