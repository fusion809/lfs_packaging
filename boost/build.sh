#!/bin/bash
set -e
name=boost
repo=boostorg/$name
version=$(gh_ver $repo)
filename="$name-$version-b2-nodocs.tar.xz"
direname="$name-$version"
depends=(which)
gha_download "$repo" "$direname" "$filename"
unpk_enter "$filename" "$direname"
./bootstrap.sh --prefix=/usr --with-python=python3 &&
./b2 stage -j$(nproc) threading=multi link=shared
oldVer=$(pkgver $name)
sudo ./b2 install threading=multi link=shared
if [[ $oldVer != $version ]]; then
	sudo rm -rf /usr/lib/cmake/boost_*-$oldVer /usr/lib/cmake/Boost-$oldVer
fi
cd ..
sudo rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
