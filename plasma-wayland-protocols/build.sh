#!/bin/bash
set -e
name=plasma-wayland-protocols
repo=KDE/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
kde_download "other" "$filename"
unpk_enter "$filename" "$direname"
export PATH=$PATH:/opt/qt6/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/qt6/lib
options=(-D CMAKE_INSTALL_PREFIX=/usr)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
