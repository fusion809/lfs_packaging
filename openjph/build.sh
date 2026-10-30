#!/bin/bash
set -e
name=openjph
_name=OpenJPH
repo=aous72/$_name
homepage="https://github.com/aous72/OpenJPH/"
description="Open-source implementation of JPEG2000 Part-15."
version=$(gh_ver $repo)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-G 'Unix Makefiles' \
        -DCMAKE_BUILD_TYPE:STRING='None' \
        -DCMAKE_INSTALL_PREFIX:PATH='/usr' \
        -DOJPH_BUILD_TESTS:BOOL='ON' \
        -Wno-dev)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
