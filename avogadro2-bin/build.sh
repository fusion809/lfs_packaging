#!/bin/bash
set -e
name=avogadro2-bin
_name=Avogadro2
repo=OpenChemistry/avogadroapp
homepage="https://two.avogadro.cc/"
description="Advanced open-soure molecule editor and informatics and 3D visualization app."
version=$(gh_ver $repo)
conflicts=(avogadroapp avogadrolibs openbabel)
filename="$_name-x86_64.AppImage"
direname="squashfs-root"
depends=(fuse)
ghr_download "$repo" "release-$version" "$filename"
chmod +x $filename
./$filename --appimage-extract
cd $direname
sudo cp -av usr/. /usr/
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
