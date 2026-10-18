#!/bin/bash
set -e
name=avogadro-crystals
_name=crystals
repo=OpenChemistry/$_name
homepage="https://openchemistry.org/"
description="Crystallographic files of common materials."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cd ..
sudo mkdir -p /usr/share/avogadro2
sudo cp -ar $direname /usr/share/avogadro2/crystals
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
