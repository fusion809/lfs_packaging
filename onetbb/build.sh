#!/bin/bash
set -e
name=onetbb
_name=oneTBB
repo=uxlfoundation/$_name
homepage="https://uxlfoundation.github.io/oneTBB/"
description="oneAPI Threading Building Blocks - a high level abstract threading library."
version=$(gh_ver $repo $name)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
arch_patch "$name" "010-onetbb-fix-linkage-of-test-malloc-pure-c.patch" || echo "Patch doesn't exist"
cmake_options=(-G "Unix Makefiles" \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DTBB_STRICT:BOOL='OFF' \
	-DTBB4PY_BUILD:BOOL='ON' \
	-DTBB_TEST:BOOL='OFF' \
	-Wno-author)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
