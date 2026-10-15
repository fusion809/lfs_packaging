#!/bin/bash
set -e
name=zed
repo=zed-industries/$name
homepage="https://zed.dev"
description="High-performance, multiplayer code editor."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cargo build --release
find . -type f -name '*.desktop' -exec sudo install -Dm644 -t /usr/share/applications {} +
sudo cat /usr/share/applications/zed.desktop | grep "^Icon="
sudo sed -i -e "s|Icon=.*$|Icon=zed|g" /usr/share/applications/$name.desktop
sudo cp -r crates/zed/resources/app-icon.png /usr/share/pixmaps/$name.png
sudo cp -r assets/images/zed_logo.svg /usr/share/icons/hicolor/scalable/apps/$name.svg
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
