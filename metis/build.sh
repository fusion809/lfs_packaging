#!/bin/bash
set -e
name=metis
_name=METIS
repo=KarypisLab/$_name
homepage="https://github.com/KarypisLab/METIS"
description="Serial graph partitioning and fill-reducing matrix ordering."
version=$(gh_ver $repo)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(gklib)
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
sed -i 's/2.8/3.10/' CMakeLists.txt
  echo "target_link_libraries(metis PUBLIC \"-lGKlib\")" >>"libmetis/CMakeLists.txt"
  # Avoid crash with illegal instruction
  sed -i 's|march=native|march=nocona|g' conf/gkbuild.cmake
  make config \
    shared=1 \
    cc=gcc \
    prefix=/usr \
    gklib_path=/usr
  sudo make install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
