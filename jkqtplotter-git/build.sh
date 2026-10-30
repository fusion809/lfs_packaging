#!/bin/bash
set -e
name=jkqtplotter-git
_name=JKQtPlotter
repo=jkriege2/JKQtPlotter
homepage="http://jkriege2.github.io/JKQtPlotter/"
description="A Qt plotting library."
version=$(gh_com $repo)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo -DJKQtPlotter_BUILD_EXAMPLES=OFF
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
