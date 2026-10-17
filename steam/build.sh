#!/bin/bash
set -e
name=steam
homepage="https://store.steampowered.com"
description="Valve's game store."
version=$(uver $name || vatver $name)
filename="${name}_latest.tar.gz"
direname="$name-launcher"
depends=(xdg-user-dirs libgpg-error)
download_src "https://repo.steampowered.com/steam/archive/stable/$filename"
unpk_enter "$filename"
sudo make PREFIX=/usr install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
