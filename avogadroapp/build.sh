#!/bin/bash
set -e
name=avogadroapp
repo=OpenChemistry/$name
homepage="https://two.avogadro.cc"
description="An advanced molecular editor."
depends=(avogadrolibs vtk hicolor-icon-theme cmake eigen pugixml utf8cpp fmt nlohmann-json fast_float)
pip_depends=(cclib)
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DUSE_VTK=ON)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
