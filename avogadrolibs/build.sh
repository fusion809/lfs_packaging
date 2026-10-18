#!/bin/bash
set -e
name=avogadrolibs
repo=OpenChemistry/$name
homepage="https://two.avogadro.cc/"
description="Libraries that provide 3D modelling, rendering, visualization, analysis, etc."
version=$(gh_ver $repo)
depends=(avogadro-crystals avogadro-fragments avogadro-molecules glew hdf5 libglvnd pugixml spglib boost cmake eigen fast_float genxrdpattern jkqtplotter libmsym mmtf-cpp nlohmann-json openmpi qt6 utf8cpp onetbb)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_C_FLAGS="$CFLAGS -ffat-lto-objects" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS -ffat-lto-objects" \
    -DUSE_HDF5=ON \
    -DUSE_PYTHON=ON \
    -DUSE_SYSTEM_GENXRDPATTERN=ON \
    -DUSE_EXTERNAL_NLOHMANN=ON \
    -DUSE_EXTERNAL_PUGIXML=ON \
    -DQT_VERSION=6)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
