#!/bin/bash
set -e
name=libde265
repo=strukturag/$name
version=$(gh_ver $repo)
depends=(cmake)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/strukturag/libde265/releases/download/v$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr \
	-D CMAKE_BUILD_TYPE=Release)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
