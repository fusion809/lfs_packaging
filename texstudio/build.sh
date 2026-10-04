#!/bin/bash
set -e
name=texstudio
repo=$name-org/$name
description="Fully featured TeX editor."
homepage="http://www.texstudio.org/"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
sudo sed -i -E "s|TEXLIVE_PREFIX=/opt/texlive/[0-9]+|TEXLIVE_PREFIX=/opt/texlive/${version:0:4}|g" $HOME/lfs-scripts/Shell/00-env.sh /etc/profile.d/texlive.sh 
source /etc/profile.d/texlive.sh
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
