#!/bin/bash
set -e
name=xdrawchem
repo=bryanherger/$name
homepage="https://bryanherger.github.io/xdrawchem/"
description="Skeletal formula sketching software."
version=$(gh_com $repo)
depends=(boost brotli bzip2 coordgen dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu keyutils libglvnd libpng libx11 libxau libxcb libxdmcp libxkbcommon maeparser mitkrb openbabel openssl pcre2 qt6 systemd xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_git "https://github.com/$repo.git"
cd $name/$name
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr
	-DCMAKE_BUILD_TYPE=Release
	-G Ninja)
cmaki "${cmake_options[@]}"
rm -rf build
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
