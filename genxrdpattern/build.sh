#!/bin/bash
set -e
name=genxrdpattern
_name=genXrdPattern
repo=psavery/$name
homepage="https://github.com/psavery/genXrdPattern"
description="Uses ObjCryst++ to generate theoretical XRD pattern."
version=$(gh_ver $repo)
filename="$_name-$version-linux.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version-linux" "$filename"
ghr_download "$repo" "$version-linux" "objcryst.tgz"
srcdir=$PWD
unpk_enter "$filename" "$direname"
export CXXFLAGS="${CXXFLAGS:-} -std=gnu++14"
tar xf ../objcryst.tgz
  sed -e 's|/user/psavery/src/objcryst/Fox/src|.|g' -i objcryst/Fox/src/Fox.dep
  sed -e 's|-march=native||' -i objcryst/ObjCryst/*.mak # Don't use -march=native
  sed -e 's|set(CMAKE_EXE_LINKER_FLAGS \"-static\")|set(CMAKE_EXE_LINKER_FLAGS "$ENV{LDFLAGS}")|' \
    -i CMakeLists.txt # Honor system LDFLAGS
  sed -e 's/indx > 0/*indx > 0/' -i objcryst/newmat/newmat6.cpp
  sed -e "s|CPPFLAGS = -w -ffast-math.*|CPPFLAGS = ${CXXFLAGS}|" -i objcryst/ObjCryst/*.mak # Honor system CFLAGS
  sed -e "s|CXXFLAGS = -O2 -Wall|CXXFLAGS = ${CXXFLAGS}|" -i objcryst/{cctbx/gnu.mak,newmat/nm_gnu.mak}
cd objcryst/Fox
make Fox-nogui shared=0 -j1
cd $srcdir/$direname
cmake_options=(
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DObjCryst_ROOT="$srcdir"/$direname/objcryst
)
mkdir build
cd build
cmake "${cmake_options[@]}" ..
make -j$(nproc)
sudo install -Dm755 genXrdPattern -t /usr/bin
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
