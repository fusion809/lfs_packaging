#!/bin/bash
set -e
name=deckcraft-bin
_name=deckcraft
repo=storytold/$_name
homepage="https://getartcraft.com/apps/deckcraft"
description="Vibe coded clean-room reimplementation of Microsoft PowerPoint."
version=$(gh_ver $repo)
filename="$_name-$version-linux-x86_64.AppImage"
direname="squashfs-root"
conflicts=(deckcraft)
ghr_download "$repo" "v$version" "$filename"
sudo chmod +x $filename
./$filename --appimage-extract
cd $direname
sudo cp -av usr/. /usr/
sudo ln -sfv /usr/share/icons/hicolor/512x512/apps/ai.storyteller.deckcraft.png \
  /usr/share/pixmaps/ai.storyteller.deckcraft.png
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
