#!/bin/bash
set -e
name=movit
homepage="https://movit.sesse.net/"
description="Modern video toolkit."
version=$(uver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(gtest sdl2-compat gcc fftw eigen glibc)
download_src "$homepage/$filename"
unpk_enter "$filename" "$direname"
arch_patch $name $name-use-system-gtest.patch
CXXFLAGS+=" --std=c++17" \
	cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
