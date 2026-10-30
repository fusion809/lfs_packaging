#!/bin/bash
set -e
name=imath
_name=Imath
repo=AcademySoftwareFoundation/$_name
homepage="https://www.openexr.com/"
description="C++/Python library for maths operations for computer graphics."
version=$(gh_ver $repo)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -DCMAKE_INSTALL_PREFIX=/usr -DPYTHON=ON
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
