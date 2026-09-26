#!/bin/bash
set -e
name=oxygen-icons
homepage="https://develop.kde.org/products/frameworks/"
description="The Oxygen Icon Theme"
repo=KDE/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
kde_download "frameworks" "$filename"
unpk_enter "$filename" "$direname"
sed -i '/( oxygen/ s/)/scalable )/' CMakeLists.txt
options=(-D CMAKE_INSTALL_PREFIX=/usr -W no-author)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
