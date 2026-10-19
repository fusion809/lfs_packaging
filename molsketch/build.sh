#!/bin/bash
set -e
name=molsketch
_name=Molsketch
repo=$name/code
homepage="https://sourceforge.net/projects/molsketch/"
description="2D molecule editor."
depends=(openbabel)
version=$(sf_ver $repo)
filename="$_name-$version-src.tar.gz"
direname="${filename/-src.tar.*/}"
download_src "https://sourceforge.net/projects/molsketch/files/Molsketch/$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr \
    -D MSK_INSTALL_LIBS64=/lib \
    -D MSK_QT6=ON \
    -D CMAKE_CXX_FLAGS="$CXXFLAGS -ffile-prefix-map=$srcdir=." \
    -G Ninja \
    -W no-dev)
cmaki "${cmake_options[@]}"
sudo sed -i -e "s|Categories=Science;|Categories=Science;Education;|g" /usr/share/applications/molsketch.desktop
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
