#!/bin/bash
set -e
name=spglib
repo=$name/$name
homepage="https://spglib.readthedocs.io/en/latest/"
description="C library for finding and handling crystal symmetries."
version=$(gh_ver $repo)
depends=(gtest)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr \
	-DSPGLIB_WITH_Fortran=ON)
cmaki "${cmake_options[@]}"
cd ..
python -m build --wheel --no-isolation
sudo python -m installer --destdir=/ dist/*.whl
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
