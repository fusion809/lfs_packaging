#!/bin/bash
set -e
name=inchi
_name=InChI
repo=IUPAC-$_name/$_name
homepage="https://github.com/IUPAC-InChI/InChI"
description="The IUPAC international chemical identifier."
version=$(gh_ver $repo)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
srcdir=$PWD
cmake_options=(
    -W no-author
    -DCMAKE_BUILD_TYPE=None
    -DCMAKE_INSTALL_PREFIX=/usr
    -DCMAKE_SKIP_RPATH=ON
  )
cd INCHI-1-SRC/INCHI_EXE/inchi-1/src
mkdir build
cd build
cmake "${cmake_options[@]}" ..
make -j$(nproc)
sudo install -vDm755 bin/inchi-1 -t /usr/bin/
cd $srcdir/INCHI-1-SRC/INCHI_API/demos/inchi_main/src
mkdir build
cd build
cmake "${cmake_options[@]}" ..
make -j$(nproc)
sudo install -vDm 755 bin/inchi_main -t /usr/bin/
sudo  install -vDm 644 bin/libinchi.so -t /usr/lib/
cd $srcdir
# install headers
for h in INCHI-1-SRC/INCHI_BASE/src/*.h INCHI-1-SRC/INCHI_API/libinchi/src/*.h; do
    sudo install -vDm 644 "$h" -t /usr/include/inchi/
done
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
