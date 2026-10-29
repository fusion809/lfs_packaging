#!/bin/bash
set -e
name=filmcraft-bin
_name=filmcraft
repo=storytold/$_name
homepage="https://getartcraft.com/apps/filmcraft"
description="Vibe coded clean-room reimplementation of Adobe Premiere Pro."
version=$(gh_ver $repo)
filename="$_name-$version-linux-x86_64.AppImage"
direname="squashfs-root"
depends=(filmcraft)
ghr_download "$repo" "v$version" "$filename"
sudo chmod +x $filename
./$filename --appimage-extract
cd $direname
sudo cp -av usr/. /usr/
sudo rm -rf /usr/share/doc/$_name
sudo ln -sfv /usr/share/icons/hicolor/512x512/apps/ai.storyteller.filmcraft.png \
  /usr/share/pixmaps/ai.storyteller.filmcraft.png
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
