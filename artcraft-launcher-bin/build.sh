#!/bin/bash
set -e
name=artcraft-launcher-bin
_name=craft-launcher
repo=storytold/$_name
homepage="https://getartcraft.com/apps/artcraft-launcher"
description="App catalogue for Artcraft apps."
version=$(gh_ver $repo)
filename="art$_name-$version-linux-x86_64.AppImage"
direname="squashfs-root"
conflicts=(artcraft-launcher)
ghr_download "$repo" "v$version" "$filename"
sudo chmod +x $filename
./$filename --appimage-extract
cd $direname
sudo cp -av usr/. /usr/
sudo rm -rf /usr/share/doc/$_name /usr/share/doc/art$_name
sudo ln -sfv /usr/share/icons/hicolor/512x512/apps/ai.storyteller.artcraft-launcher.png \
  /usr/share/pixmaps/ai.storyteller.artcraft-launcher.png
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
