#!/bin/bash
set -e
name=gklib
_name=GKlib
repo=KarypisLab/$_name
homepage=""
description=""
version=$(gh_ver $repo)
filename="METIS-v$version-DistDGL-0.5.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$direname" "$filename"
unpk_enter "$filename"
wget -c "https://github.com/KarypisLab/GKlib/commit/33b8c8bb8dada74b824badff961532f11d0d5e1c.patch" -O gk_GetProcVmPeak.patch
wget -c "https://github.com/KarypisLab/GKlib/commit/1403a04bc40a306d09adfccced7d903d69de040a.patch" -O gk_creadfilebin.patch
patch -p1 -i gk_GetProcVmPeak.patch
  patch -p1 -i gk_creadfilebin.patch
  # Enable shared library and use Makefiles
  sed -i 's/CONFIG_FLAGS = -DCMAKE_VERBOSE_MAKEFILE=1/CONFIG_FLAGS = -DBUILD_SHARED_LIBS=TRUE -DCMAKE_GENERATOR="Unix Makefiles"/' Makefile
  # Increase CMake version
  sed -i 's/2.8/3.10/' CMakeLists.txt
  # Avoid crash with illegal instruction
  sed -i 's|march=native|march=nocona|' GKlibSystem.cmake
  make config \
    cc=gcc \
    prefix=/usr
  sudo make install
cd ../
rm -rf "$filename" *"$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
