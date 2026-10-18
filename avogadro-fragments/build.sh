#!/bin/bash
set -e
name=avogadro-fragments
_name=fragments
repo=OpenChemistry/$_name
homepage="https://openchemistry.org/"
description="Molecular fragments and inorganic ligands."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cd ..
sudo mkdir -p /usr/share/avogadro2
sudo cp -ar $direname /usr/share/avogadro2/fragments
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
