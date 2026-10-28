#!/bin/bash
set -e
name=effectcraft-bin
_name=effectcraft
repo=storytold/$_name
homepage="https://getartcraft.com/apps/effectcraft"
description="Vibe coded clean-room reimplementation of Adobe After Effects."
version=$(gh_ver $repo)
filename="$_name-$version-linux-x86_64.AppImage"
direname="squashfs-root"
conflicts=(effectcraft)
ghr_download "$repo" "v$version" "$filename"
sudo chmod +x $filename
./$filename --appimage-extract
cd $direname
sudo cp -av usr/. /usr/
sudo ln -sfv /usr/share/icons/hicolor/512x512/apps/ai.storyteller.effectcraft.png \
  /usr/share/pixmaps/ai.storyteller.effectcraft.png
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
