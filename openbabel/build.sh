#!/bin/bash
set -e
name=openbabel
repo=$name/$name
homepage="https://openbabel.org/"
description="Library to convert between multiple chemical file formats."
version=$(gh_ver $repo)
_version=(echo $version | tr '.' '-')
filename="$name-$_version.tar.gz"
direname="$name-${filename/.tar.*/}"
depends=(wxwidgets-gtk3 maeparser inchi coordgen cairo zlib eigen rapidjson glibc libxml2)
gha_download "$repo" "$name-$_version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr \
    -DRUN_SWIG=ON \
    -DPYTHON_BINDINGS=ON \
    -DOPENBABEL_USE_SYSTEM_INCHI=ON)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
