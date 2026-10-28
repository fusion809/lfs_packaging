#!/bin/bash
set -e
name=wordcraft-bin
_name=wordcraft
repo=storytold/$_name
homepage="https://getartcraft.com/apps/wordcraft"
description="Vibe coded clean-room reimplementation of Microsoft Word."
version=$(gh_ver $repo)
depends=(gcc glibc)
conflicts=(wordcraft)
filename="$_name-$version-linux-x86_64.AppImage"
direname="squashfs-root"
ghr_download "$repo" "v$version" "$filename"
sudo chmod +x $filename
./$filename --appimage-extract
cd $direname
sudo cp -av usr/. /usr/
sudo ln -sfv /usr/share/icons/hicolor/512x512/apps/ai.storyteller.wordcraft.png \
  /usr/share/pixmaps/ai.storyteller.wordcraft.png
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
