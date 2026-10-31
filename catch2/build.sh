#!/bin/bash
set -e
name=catch2
repo=catchorg/$name
homepage="https://github.com/catchorg/catch2"
description="Modern C++ native header-only test framework."
version=$(gh_ver $repo)
gitcommit=$(wget -cqO- -T 5 -t 1 "https://gitlab.archlinux.org/archlinux/packaging/packages/catch2-v2/-/raw/main/PKGBUILD?ref_type=heads" | grep "_gitcommit=" | cut -d '=' -f 2)
filename="$name-$gitcommit.tar.gz"
direname="Catch2-$gitcommit"
gha_download "$repo" "$gitcommit" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCATCH_USE_VALGRIND=OFF \
    -DCATCH_BUILD_EXAMPLES=OFF \
    -DCATCH_ENABLE_COVERAGE=OFF \
    -DCATCH_ENABLE_WERROR=OFF \
    -DBUILD_TESTING=ON)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
