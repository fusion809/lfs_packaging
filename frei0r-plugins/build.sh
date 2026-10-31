#!/bin/bash
set -e
name=frei0r-plugins
_name=frei0r
repo=dyne/$_name
homepage="https://frei0r.dyne.org/"
description="Video effect plugins collection."
version=$(gh_ver $repo)
depends=(cairo gavl glibc gcc libglvnd opencv)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
arch_patch "$name" "opencv-5.patch"
cmaki -DCMAKE_INSTALL_PREFIX=/usr -DWITHOUT_FACERECOGNITION=ON
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
