#!/bin/bash
set -e
name=libmsym
repo=mcodev31/$name
homepage="https://openchemistry.org"
description="Molecular point group symmetry IIb"
version=$(gh_ver $repo)
filename="$name-$version-paper.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version-paper" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr \
	-DBUILD_SHARED_LIBS=ON \
	-DMSYM_BUILD_PYTHON=ON \
	-DMSYM_PYTHON_INSTALL_OPTS=--root=/ \
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5
)
cmaki "${cmake_options[@]}"
cd ../..
sudo rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
