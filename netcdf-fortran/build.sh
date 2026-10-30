#!/bin/bash
set -e
name=netcdf-fortran
repo=Unidata/$name
homepage="https://github.com/Unidata/netcdf-fortran"
description="NetCDF Fortran bindings."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_FILTER_TEST=ON \
    -DENABLE_LARGE_FILE_TESTS=ON \
    -DTEST_WITH_VALGRIND=ON)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
