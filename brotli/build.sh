#!/bin/bash
set -e
name=brotli
homepage="https://github.com/google/brotli"
description="Generic-purpose lossless compression algorithm"
repo=google/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(cmake)
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(
    -D CMAKE_INSTALL_PREFIX=/usr        \
	-D CMAKE_BUILD_TYPE=Release  \
	-G Ninja
)
cmaki "${cmake_options[@]}"
cd ..

sed -e '/libraries +=/s/=.*/= [required_system_library[3:]]/' \
    -e '/package_configuration/d'                             \
    -e '/pkgconfig/d'                                         \
    -i setup.py                                               &&

USE_SYSTEM_BROTLI=1 \
pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
sudo pip3 install --no-index --find-links dist --no-user Brotli
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
