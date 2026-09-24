#!/bin/bash
set -e
name=xdotool
repo=jordansissel/$name
version=$(gh_ver $repo)
depends=(glibc libX11 libXau libxcb libXdmcp libXext libXi libXinerama libxkbcommon libxtst)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
make WITHOUT_RPATH_FIX=1 -j$(nproc)
sudo make PREFIX=/usr INSTALLMAN=/usr/share/man install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
