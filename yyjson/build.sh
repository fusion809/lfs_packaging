#!/bin/bash
set -e
name=yyjson
homepage="https://ibireme.github.io/yyjson"
description="A high performance JSON library written in ANSI C"
repo=ibireme/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(bash cmake coreutils glibc gzip tar)
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(
	-DCMAKE_BUILD_TYPE='None' \
	-DCMAKE_INSTALL_PREFIX='/usr' \
	-DBUILD_SHARED_LIBS='ON' \
	-DYYJSON_BUILD_TESTS='ON' \
	-Wno-dev
)
cmaki "${cmake_options[@]}"
cd ..
sudo mkdir -p /usr/share/doc/$direname
sudo install -Dm644 README.md /usr/share/doc/$direname
sudo install -Dm644 doc/*.md /usr/share/doc/$direname
# Cleanup and add to database
cd ..
rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
