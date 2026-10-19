#!/bin/bash
set -e
name=mmtf-cpp
repo=rcsb/$name
homepage="http://mmtf.rcsb.org/"
description="C++ implementation of MMTF API, de/encoder."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -DCMAKE_INSTALL_PREFIX=/usr
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
