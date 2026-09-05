#!/bin/bash
set -e
name=double-conversion
repo=google/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(cmake)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/google/brotli/archive/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr        \
      -D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
      -D BUILD_SHARED_LIBS=ON             \
      -D BUILD_TESTING=ON)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
