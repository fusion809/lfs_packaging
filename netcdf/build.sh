#!/bin/bash
set -e
name=netcdf
_name=netcdf-c
repo=Unidata/$_name
homepage="https://www.unidata.ucar.edu/software/netcdf/"
description="Network common data form interface."
version=$(gh_ver $repo)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DNETCDF_WITH_PLUGIN_DIR=/usr/lib/netcdf/plugin \
    -DNETCDF_ENABLE_BYTERANGE=ON \
    -DNETCDF_ENABLE_CDF5=ON \
    -DNETCDF_ENABLE_DAP_LONG_TESTS=ON \
    -DNETCDF_ENABLE_DAP_REMOTE_TESTS=ON \
    -DNETCDF_ENABLE_EXAMPLE_TESTS=ON \
    -DNETCDF_ENABLE_EXTRA_TESTS=ON \
    -DNETCDF_ENABLE_FILTER_TESTING=ON \
    -DNETCDF_ENABLE_LARGE_FILE_TESTS=ON \
    -DNETCDF_ENABLE_UNIT_TESTS=ON \
    -DNETCDF_ENABLE_LOGGING=ON \
    -DNETCDF_PLUGIN_INSTALL=ON
)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
