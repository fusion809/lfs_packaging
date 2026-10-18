#!/bin/bash
set -e
name=onetbb
_name=oneTBB
repo=uxlfoundation/$_name
homepage="https://uxlfoundation.github.io/oneTBB/"
description="oneAPI Threading Building Blocks - a high level abstract threading library."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-G "Unix Makefiles" \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_BUILD_TYPE:STRING="none" \
	-DTBB_STRICT:BOOL='OFF' \
	-DTBBY4PY_BUILD:BOOL='ON' \
	-Wno-author)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
