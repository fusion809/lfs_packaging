#!/bin/bash
set -e
name=coordgen
_name=coordgenlibs
repo=schrodinger/coordgenlibs
homepage="https://github.com/schrodinger/coordgenlibs"
description="Schrodinger-developed 2D coordinate generation."
version=$(gh_ver $repo)
depends=(maeparser)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
arch_patch "$name" "fix-cmake.patch"
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr \
    -DCOORDGEN_USE_MAEPARSER=ON \
    -DCOORDGEN_BUILD_TESTS=OFF \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
