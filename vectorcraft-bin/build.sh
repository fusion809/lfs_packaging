#!/bin/bash
set -e
name=vectorcraft-bin
_name=vectorcraft
repo=storytold/$_name
homepage="https://getartcraft.com/apps/vectorcraft"
description="Vibe coded clean-room reimplementation of Adobe Illustrator."
version=$(gh_ver $repo)
filename="$_name-$version-linux-x86_64.AppImage"
direname="squashfs-root"
ghr_download "$repo" "v$version" "$filename"
sudo chmod +x $filename
./$filename --appimage-extract
cd $direname
sudo cp -av usr/. /usr/
sudo ln -sfv /usr/share/icons/hicolor/512x512/apps/ai.storyteller.vectorcraft.png \
  /usr/share/pixmaps/ai.storyteller.vectorcraft.png
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
